# WebClient Architecture & Best Practices

## 📋 Översikt

Detta dokument beskriver hur service-to-service kommunikation fungerar i TrafficSchool microservice-arkitekturen med Spring Cloud WebClient och Eureka.

---

## 🏗️ Arkitektur

### Service Communication Flow

```
┌─────────────────┐
│   API Gateway   │ (8080)
│   (Eureka)      │
└────────┬────────┘
         │
    ┌────┴────────────────────┬──────────────┬─────────────┐
    │                         │              │             │
┌───▼──────┐    ┌────────────▼──┐    ┌─────▼──────┐   ┌─▼──────────┐
│  Admin   │───>│  User Service │    │   Payment  │   │    Quiz    │
│ Service  │    │    (8081)     │    │   Service  │   │  Service   │
│ (8084)   │    └───────────────┘    │   (8085)   │   │   (8082)   │
└──────┬───┘                         └──────┬─────┘   └────────────┘
       │                                    │
       │                                    └───> User Service
       │
       └───> Payment Service
       └───> Quiz Service
       └───> Exam Service
```

### WebClient Services

| Service             | Has WebClient | Calls Services            | Purpose                            |
| ------------------- | ------------- | ------------------------- | ---------------------------------- |
| **admin-service**   | ✅ Yes        | user, payment, quiz, exam | Admin operations delegation        |
| **payment-service** | ✅ Yes        | user                      | Create subscriptions after payment |
| **exam-service**    | ✅ Yes        | quiz                      | Fetch questions for exams          |
| **quiz-service**    | ❌ No         | -                         | No service-to-service calls needed |
| **user-service**    | ❌ No         | -                         | No service-to-service calls needed |

---

## 🔧 WebClient Configuration

### Standard Pattern

```java
@Configuration
public class WebClientConfig {

    @Bean
    @LoadBalanced  // ⚡ Enables Eureka service discovery
    public WebClient.Builder loadBalancedWebClientBuilder() {
        return WebClient.builder();
    }

    @Bean
    public WebClient targetServiceWebClient(WebClient.Builder builder) {
        return builder
                .baseUrl("http://service-name")  // 🌐 Eureka service name
                .defaultHeader("X-Internal-Source", "calling-service")
                .build();
    }
}
```

### Key Components

1. **@LoadBalanced**
   - Enables Eureka service discovery
   - Resolves `http://service-name` → `http://localhost:PORT`
   - Load balances between multiple instances

2. **baseUrl()**
   - Use Eureka service name (e.g., `http://user-service`)
   - NOT `http://localhost:8081`
   - Eureka resolves the actual IP:PORT

3. **defaultHeader()**
   - `X-Internal-Source`: Identifies calling service
   - `X-Internal-API-Key`: Optional service-to-service authentication
   - `Content-Type`: Standard headers

---

## 📝 Usage Examples

### Admin Service → User Service

**Configuration:**

```java
@Bean
public WebClient userServiceWebClient(WebClient.Builder builder) {
    return builder
            .baseUrl("http://user-service")
            .defaultHeader("X-Internal-Source", "admin-service")
            .build();
}
```

**Service Usage:**

```java
@Service
public class AdminUserService {

    private final WebClient userServiceWebClient;

    public List<UserDTO> getAllUsers() {
        return userServiceWebClient.get()
                .uri("/api/users")
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<List<UserDTO>>() {})
                .block();
    }
}
```

### Payment Service → User Service (with API Key)

**Configuration:**

```java
@Bean
public WebClient userServiceWebClient(WebClient.Builder builder) {
    return builder
            .baseUrl("http://user-service")
            .defaultHeader("X-Internal-API-Key", serviceApiKey)
            .defaultHeader("X-Internal-Source", "payment-service")
            .build();
}
```

**Service Usage:**

```java
public void createSubscription(Long userId, Long packageId) {
    CreateSubscriptionRequestDTO request = new CreateSubscriptionRequestDTO(userId, packageId);

    userServiceWebClient.post()
            .uri("/api/subscriptions")
            .bodyValue(request)
            .retrieve()
            .bodyToMono(String.class)
            .block();
}
```

### Exam Service → Quiz Service

**Configuration:**

```java
@Bean
public WebClient quizWebClient(WebClient.Builder builder) {
    return builder
            .baseUrl("http://quiz-service/api/quizzes")
            .defaultHeader("X-Internal-Source", "exam-service")
            .build();
}
```

**Service Usage:**

```java
public List<QuizQuestionDTO> getQuestions(List<Integer> subjects, int limit) {
    return quizWebClient.get()
            .uri(uriBuilder -> uriBuilder
                    .path("/subjects")
                    .queryParam("subjects", subjects)
                    .queryParam("limit", limit)
                    .build())
            .retrieve()
            .bodyToMono(new ParameterizedTypeReference<List<QuizQuestionDTO>>() {})
            .block();
}
```

---

## 🎯 Best Practices

### ✅ DO

1. **Use @LoadBalanced**

   ```java
   @Bean
   @LoadBalanced
   public WebClient.Builder loadBalancedWebClientBuilder()
   ```

2. **Use Eureka service names**

   ```java
   .baseUrl("http://user-service")  // ✅ Good
   ```

3. **Add X-Internal-Source header**

   ```java
   .defaultHeader("X-Internal-Source", "admin-service")
   ```

4. **Use ParameterizedTypeReference for collections**

   ```java
   .bodyToMono(new ParameterizedTypeReference<List<UserDTO>>() {})
   ```

5. **Handle errors appropriately**
   ```java
   .onErrorResume(error -> {
       log.error("Error: {}", error.getMessage());
       return Mono.empty();
   })
   ```

### ❌ DON'T

1. **Don't hardcode localhost URLs**

   ```java
   .baseUrl("http://localhost:8081")  // ❌ Bad
   ```

2. **Don't forget @LoadBalanced**

   ```java
   @Bean
   public WebClient.Builder builder() {  // ❌ Missing @LoadBalanced
       return WebClient.builder();
   }
   ```

3. **Don't use RestTemplate for internal calls**

   ```java
   RestTemplate restTemplate = new RestTemplate();  // ❌ Use WebClient
   ```

4. **Don't expose internal endpoints externally**
   ```java
   // ❌ Bad - Internal endpoint exposed through gateway
   @GetMapping("/api/internal/users")
   ```

---

## 🔒 Security Considerations

### Internal API Keys

Some services use API keys for service-to-service authentication:

```java
@Value("${service.api.key}")
private String serviceApiKey;

@Bean
public WebClient userServiceWebClient(WebClient.Builder builder) {
    return builder
            .baseUrl("http://user-service")
            .defaultHeader("X-Internal-API-Key", serviceApiKey)
            .build();
}
```

**application.properties:**

```properties
service.api.key=your-secure-api-key
```

### X-Internal-Source Header

All WebClients should include this header to identify the calling service:

```java
.defaultHeader("X-Internal-Source", "admin-service")
```

This can be used for:

- Logging and monitoring
- Request tracing
- Security filtering
- Rate limiting per service

---

## 📊 Monitoring & Logging

### Request Logging

```java
@Service
@Slf4j
public class AdminUserService {

    public UserDTO getUser(Long id) {
        log.info("🔍 Fetching user {} from user-service", id);

        UserDTO user = userServiceWebClient.get()
                .uri("/api/users/{id}", id)
                .retrieve()
                .bodyToMono(UserDTO.class)
                .block();

        log.info("✅ User fetched successfully: {}", id);
        return user;
    }
}
```

### Error Handling

```java
public UserDTO getUser(Long id) {
    try {
        return userServiceWebClient.get()
                .uri("/api/users/{id}", id)
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError,
                    response -> Mono.error(new NotFoundException("User not found")))
                .onStatus(HttpStatusCode::is5xxServerError,
                    response -> Mono.error(new ServiceUnavailableException("User service down")))
                .bodyToMono(UserDTO.class)
                .block();
    } catch (Exception e) {
        log.error("❌ Error fetching user {}: {}", id, e.getMessage());
        throw new RuntimeException("Failed to fetch user", e);
    }
}
```

---

## 🔄 Migration Checklist

When adding WebClient to a new service:

- [ ] Add `spring-boot-starter-webflux` dependency
- [ ] Add `spring-cloud-starter-netflix-eureka-client` dependency
- [ ] Create `WebClientConfig.java` class
- [ ] Add `@LoadBalanced` WebClient.Builder bean
- [ ] Create service-specific WebClient beans
- [ ] Add `X-Internal-Source` header
- [ ] Update service layer to use WebClient
- [ ] Remove old RestTemplate code
- [ ] Add proper error handling
- [ ] Add logging
- [ ] Test service-to-service communication

---

## 📦 Required Dependencies

### pom.xml

```xml
<dependencies>
    <!-- WebClient (Reactive HTTP Client) -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>

    <!-- Eureka Client (includes LoadBalancer) -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>
</dependencies>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>2025.0.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

---

## 🧪 Testing

### Mock WebClient in Tests

```java
@SpringBootTest
class AdminUserServiceTest {

    @MockBean
    private WebClient userServiceWebClient;

    @Test
    void testGetUser() {
        // Mock WebClient response
        when(userServiceWebClient.get()
                .uri(anyString())
                .retrieve()
                .bodyToMono(UserDTO.class))
                .thenReturn(Mono.just(new UserDTO()));

        // Test service method
        UserDTO user = adminUserService.getUser(1L);
        assertNotNull(user);
    }
}
```

---

## 📚 Summary

### Current WebClient Setup

| Service         | WebClient Config | Target Services           |
| --------------- | ---------------- | ------------------------- |
| admin-service   | ✅ Complete      | user, payment, quiz, exam |
| payment-service | ✅ Complete      | user                      |
| exam-service    | ✅ Complete      | quiz                      |
| quiz-service    | ❌ Not needed    | -                         |
| user-service    | ❌ Not needed    | -                         |

### Architecture Benefits

✅ **Service Discovery**: Automatic routing via Eureka  
✅ **Load Balancing**: Built-in with @LoadBalanced  
✅ **Resilience**: Reactive error handling  
✅ **Scalability**: Easy to add new services  
✅ **Monitoring**: X-Internal-Source header tracking  
✅ **Security**: Internal API key support

---

## 🔗 Related Documentation

- [Spring Cloud LoadBalancer](https://spring.io/guides/gs/spring-cloud-loadbalancer/)
- [WebClient Documentation](https://docs.spring.io/spring-framework/reference/web/webflux-webclient.html)
- [Eureka Service Discovery](https://spring.io/guides/gs/service-registration-and-discovery/)

---

**Last Updated:** 2026-02-23  
**Version:** 1.0  
**Maintained by:** TrafficSchool DevOps Team
