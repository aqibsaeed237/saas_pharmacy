# PROGRAMMING FUNDAMENTALS — Senior Level

> **Versatile, detailed guide** for Flutter/Dart developers. Each topic includes: definition, types/subtypes, deep explanation, examples, solutions, and use cases. References **Pharmacy POS** project.

---

## How to Use This Document

| Section Type | What You Get |
|--------------|--------------|
| **Definition** | Clear, concise meaning |
| **Types/Subtypes** | Breakdown by category (e.g., polymorphism types, key types) |
| **Detail** | Deep dive with reasoning |
| **Examples** | Code samples from Pharmacy POS |
| **Solution** | Step-by-step approach, best practices |
| **Use Case** | When to apply, when to avoid |

---

## Table of Contents
1. [Core Concepts](#core-concepts)
2. [Advanced Concepts](#advanced-concepts)
3. [Dart (Advanced)](#dart-advanced)
4. [Flutter (Mid → Senior)](#flutter-mid--senior)
5. [Mobile App Development](#mobile-app-development)
6. [Backend & API Integration](#backend--api-integration)
7. [Firebase](#firebase)
8. [Databases](#databases)
9. [Security](#security)
10. [DevOps / CI-CD](#devops--ci-cd)
11. [System Design](#system-design)
12. [Soft Skills](#soft-skills)
13. [Scenario / Behavioral](#scenario--behavioral)
14. [Trick Questions](#trick-questions)

---

# CORE CONCEPTS

## 1. OOP Principles with Real Project Examples

### **Encapsulation**
Bundling data and methods that operate on that data within a single unit, hiding internal implementation.

**Pharmacy POS Example:**
```dart
// lib/domain/entities/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
  });

  // Business logic encapsulated - can't modify stock directly
  Product reduceStock(int quantity) {
    if (quantity > stockQuantity) throw StateError('Insufficient stock');
    return Product(id: id, name: name, price: price, stockQuantity: stockQuantity - quantity);
  }
}
```

### **Inheritance**
Child classes inherit properties and methods from parent classes.

**Example:**
```dart
abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  BaseEntity({required this.id, required this.createdAt});
}

class Product extends BaseEntity {
  final String name;
  Product({required super.id, required super.createdAt, required this.name});
}
```

### **Polymorphism**
Same interface, different implementations.

**Example:**
```dart
abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(LoginRequest request);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, AuthResponse>> login(LoginRequest request) async {
    // API implementation
  }
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, AuthResponse>> login(LoginRequest request) async {
    // Mock for testing
  }
}
```

### **Abstraction**
Hiding complex implementation, exposing only essential features.

**Example:** `AuthRepository` is an abstract interface. `AuthBloc` doesn't know if it's calling REST API, GraphQL, or mock data.

---

### **OOP Types & Subtypes — Deep Dive**

| Principle | Types | Solution When Violated |
|-----------|-------|------------------------|
| **Encapsulation** | Data hiding, Access modifiers (public/private), Getters/setters | Use `final` + methods for mutations; avoid public mutable fields |
| **Inheritance** | Single, Multi-level, Hierarchical | Prefer composition; use mixins for shared behavior |
| **Polymorphism** | Compile-time (overloading), Runtime (overriding) | Use abstract methods; implement interfaces |
| **Abstraction** | Abstract classes, Interfaces | Define contracts; hide implementation details |

**Polymorphism Types in Dart:**
- **Runtime (Overriding):** `@override` — child replaces parent method
- **Ad-hoc (Overloading):** Dart has no overloading; use named params or optional params
- **Parametric (Generics):** `List<T>`, `Either<L, R>` — same code, different types

**Solution — Fixing OOP Violations:**
1. **Leaky encapsulation:** Move validation inside entity; expose only `copyWith`/immutable methods
2. **Deep inheritance:** Extract to mixins; use composition
3. **Wrong abstraction:** Split fat interface; use Interface Segregation

---

## 2. Abstract Class vs Interface

| Aspect | Abstract Class | Interface |
|--------|----------------|-----------|
| **Definition** | Can have abstract + concrete methods, constructors, state | Pure contract — only method signatures |
| **Inheritance** | Single inheritance | Multiple implementation |
| **State** | Can hold fields | No fields (Dart 2.x+) |
| **Constructor** | Can have | Cannot have |

### **Abstract Class — Use Case**
When you need shared implementation + extension points.

```dart
abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState);

  void handleFailure(Failure failure) {
    // Shared error handling logic
    logError(failure.message);
  }
}

class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial());
  // Inherits handleFailure
}
```

### **Interface — Use Case**
When you need a contract without implementation (Dart uses `abstract class` for this).

```dart
// lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(LoginRequest request);
  Future<Either<Failure, void>> logout();
}
```

**Dart Note:** Dart has no `interface` keyword. Use `abstract class` with no implementation.

### **Types of Abstract Classes in Dart**

| Type | Use Case | Example |
|------|----------|---------|
| **Pure interface** | Contract only, no implementation | `AuthRepository` |
| **Partial implementation** | Shared logic + extension points | `BaseBloc` with `handleFailure` |
| **Abstract with factory** | Force factory constructors | `Either.left()` / `Either.right()` |

### **Solution — Choosing Abstract vs Interface**
- Need **shared code** → Abstract class
- Need **contract only** → Abstract class (Dart) or pure abstract
- Need **multiple contracts** → Multiple `implements` (Dart allows)

---

## 3. SOLID Principles

| Principle | Meaning | Flutter Violation |
|-----------|---------|-------------------|
| **S**ingle Responsibility | One class, one reason to change | God Widgets, Blocs doing API + UI logic |
| **O**pen/Closed | Open for extension, closed for modification | Hardcoding payment types instead of strategy |
| **L**iskov Substitution | Subtypes must be substitutable for base | Breaking contract in repository implementations |
| **I**nterface Segregation | Many specific interfaces > one fat interface | Repository with 20 methods when screen needs 2 |
| **D**ependency Inversion | Depend on abstractions, not concretions | `AuthBloc` depending on `AuthRepositoryImpl` directly |

### **Most Violated in Flutter: Single Responsibility**
- Screens with API calls, validation, navigation, and business logic
- Blocs handling both state and side effects (API, storage)
- Widgets with 500+ lines

**Pharmacy POS — Good Example (SRP):**
- `LoginUseCase` — only orchestrates login
- `AuthRepository` — only defines contract
- `AuthBloc` — only manages auth state
- `LoginScreen` — only UI

### **SOLID — Solution for Each Violation**

| Violation | Solution |
|-----------|----------|
| **SRP:** God Widget | Extract `LoginForm`, `LoginButton`; move logic to Bloc/UseCase |
| **OCP:** Hardcoded payment types | Strategy pattern: `PaymentStrategy` interface, `CardPayment`, `CashPayment` |
| **LSP:** Repository returns wrong type | Ensure `MockAuthRepository` behaves like `AuthRepositoryImpl`; same contract |
| **ISP:** Fat repository | Split: `AuthReadRepository`, `AuthWriteRepository` |
| **DIP:** Bloc depends on impl | Inject `AuthRepository` (abstract); use DI container |

### **SOLID Types — Quick Reference**
- **S** — One reason to change
- **O** — Extend via new classes, not modify existing
- **L** — Subtypes must not break supertype contract
- **I** — Small, focused interfaces
- **D** — High-level modules don't depend on low-level; both depend on abstractions

---

## 4. Design Patterns — Production Examples

| Pattern | Definition | Pharmacy POS Usage |
|---------|------------|-------------------|
| **Repository** | Abstracts data source | `AuthRepository`, `ProductRepository` |
| **Use Case** | Single business action | `LoginUseCase`, `CreateSaleUseCase` |
| **BLoC** | Business Logic Component | `AuthBloc`, `ProductBloc`, `SaleBloc` |
| **Factory** | Creates objects without specifying exact class | `Either.left(Failure())` / `Either.right(data)` |
| **Singleton** | One instance globally | `AppConfig`, Router |
| **Observer** | Notify dependents of state changes | `BlocBuilder`, `StreamBuilder` |
| **Dependency Injection** | Inject dependencies from outside | `AuthBloc(loginUseCase: ...)` |
| **Adapter** | Adapt external API to internal interface | `ProductModel.fromJson()` → `Product` entity |

### **Design Pattern Types (GoF Categories)**

| Category | Patterns | Pharmacy POS Usage |
|----------|----------|-------------------|
| **Creational** | Singleton, Factory, Builder | `AppConfig`, `Either.left/right`, `Product.copyWith` |
| **Structural** | Adapter, Facade, Proxy | `ProductModel` → `Product`, API client wrapper |
| **Behavioral** | Observer, Strategy, Command | `BlocBuilder`, Payment strategies, `AuthEvent` |

### **Pattern Selection — Solution Guide**
- **Need single instance?** → Singleton (`AppConfig`)
- **Need to abstract data source?** → Repository
- **Need one business action?** → Use Case
- **Need event-driven UI?** → BLoC / Observer
- **Need swappable algorithms?** → Strategy (payment types)
- **Need to adapt external API?** → Adapter (JSON → Entity)

---

## 5. Composition vs Inheritance

### **Inheritance**
"is-a" relationship. Child extends parent.

```dart
class Dog extends Animal { }
```

### **Composition**
"has-a" relationship. Object contains other objects.

```dart
class AuthBloc {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  AuthBloc({required this.loginUseCase, required this.logoutUseCase});
}
```

### **Preference: Composition**
- **Flexibility:** Swap implementations without changing hierarchy
- **Testing:** Easy to mock dependencies
- **Avoids:** Fragile base class, diamond problem
- **Flutter:** Prefer composition (widgets, mixins) over deep inheritance

**Pharmacy POS:** `AuthBloc` composes `LoginUseCase`, `LogoutUseCase` — not inheriting from a "BaseAuthBloc".

---

## 6. Handling Tight Coupling

**Tight Coupling:** Components depend on concrete implementations, making changes risky.

### **Strategies:**

1. **Dependency Injection**
   ```dart
   AuthBloc(loginUseCase: getIt<LoginUseCase>())
   ```

2. **Abstractions (Interfaces)**
   ```dart
   class AuthBloc {
     final AuthRepository repository; // Abstract, not AuthRepositoryImpl
   }
   ```

3. **Event-Driven Communication**
   - Blocs emit events; screens listen. No direct screen-to-screen calls.

4. **Clean Architecture Layers**
   - Domain doesn't know Data. Presentation doesn't know Data.
   - Dependencies point inward.

5. **Feature Modules**
   - Isolate features. Auth module doesn't import Sales module directly.

### **Types of Coupling — Detail**

| Type | Description | Solution |
|------|-------------|----------|
| **Content** | A uses B's internals | Use public API only; encapsulate |
| **Common** | A and B share global state | Inject dependencies; avoid globals |
| **Control** | A controls B's flow | Use events; invert control |
| **Stamp** | A passes whole object when B needs few fields | Pass only required data |
| **Data** | A and B share data structure | Use DTOs; keep domain pure |

### **Solution — Decoupling Checklist**
1. Replace `new ConcreteClass()` with constructor injection
2. Depend on `abstract class` / interface
3. Use event bus for cross-feature communication
4. Split features into modules; avoid circular imports
5. Use `--no-implicit-casts` to catch type coupling

---

## 7. Dependency Injection — Definition, Importance, Example

### **Definition**
Dependency Injection (DI) is a design pattern where objects receive their dependencies from an external source rather than creating or looking them up internally. The dependent object doesn't know how to construct its dependencies—it only knows their interface.

### **Why It Matters**
- **Testability:** Inject mocks (e.g., `MockAuthRepository`) without changing production code
- **Flexibility:** Swap implementations (prod vs staging API, real vs fake)
- **Single Responsibility:** Classes don't create their own dependencies—they focus on their job
- **Loose Coupling:** Depend on abstractions (interfaces), not concrete classes
- **Maintainability:** Change implementations in one place (DI container)

### **Concept**
```
Without DI:  AuthBloc → creates → LoginUseCase → creates → AuthRepositoryImpl
With DI:    AuthBloc ← receives ← LoginUseCase ← receives ← AuthRepository (abstraction)
```

### **Example — Pharmacy POS**

```dart
// ❌ Without DI (tight coupling) — hard to test, hard to change
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _loginUseCase = LoginUseCase(
    AuthRepositoryImpl(AuthApiService(), SecureStorage()),
  );
  // Can't test without hitting real API!
}

// ✅ With DI (loose coupling) — testable, flexible
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  AuthBloc({required this.loginUseCase});

  // In test: AuthBloc(loginUseCase: MockLoginUseCase())
  // In prod: AuthBloc(loginUseCase: getIt<LoginUseCase>())
}
```

### **DI Setup Example (get_it)**
```dart
// main.dart or injection.dart
final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(loginUseCase: getIt()));
}
```

### **DI Types — Detail**

| Type | How | Use Case |
|------|-----|----------|
| **Constructor** | Dependencies in constructor | Preferred; explicit, testable |
| **Setter** | `setRepository(repo)` | Optional deps; rare in Flutter |
| **Interface** | Implement injector interface | Advanced; framework integration |
| **Service Locator** | `getIt<T>()` | Global access; use sparingly |

### **DI in Flutter**
- **Manual:** Constructor injection (as above) — simple, explicit
- **get_it / injectable:** Service locator — register once, resolve anywhere
- **Provider / Riverpod:** Widget tree injection — scoped to widget subtree
- **flutter_bloc:** `RepositoryProvider`, `BlocProvider` — Bloc-specific DI

### **Solution — DI Best Practices**
1. Prefer constructor injection
2. Register abstractions, resolve abstractions
3. Use `registerFactory` for Blocs (new per screen)
4. Use `registerLazySingleton` for repositories
5. Avoid service locator in domain layer

---

# ADVANCED CONCEPTS

## 1. Immutability and Performance

**Immutability:** Data cannot be changed after creation. New copies are created for "changes."

**Impact on Performance:**
- **Pros:** Predictable, thread-safe, easier caching, no accidental mutations
- **Cons:** More allocations (copying) — can increase GC pressure
- **Flutter:** `const` widgets skip rebuilds. Immutable state (Bloc) enables efficient diffing.

```dart
// Immutable Product
class Product {
  final String id;
  final int stock;
  Product copyWith({int? stock}) => Product(id: id, stock: stock ?? this.stock);
}
```

### **Immutability Types & Solutions**

| Type | Example | Solution |
|------|---------|----------|
| **Shallow** | `final list = [1,2]` — list ref immutable, contents mutable | Use `List.unmodifiable` or immutable collections |
| **Deep** | All nested objects immutable | `copyWith` for nested; avoid mutable fields |
| **Structural sharing** | `copyWith` reuses unchanged fields | Reduces allocations; good for Bloc state |

**Solution — When Mutable:**
- Form controllers (`TextEditingController`) — must mutate
- Animation controllers — must mutate
- Keep domain entities immutable

---

## 2. Pure Functions

**Definition:** Same inputs → same outputs. No side effects (no I/O, no mutable state).

**Why Important:**
- Easy to test
- Cacheable (memoization)
- Parallelizable
- Predictable

```dart
// Pure
double calculateTax(double price, double rate) => price * rate;

// Impure
double calculateTax(double price) => price * getTaxRateFromDB(); // Side effect
```

### **Pure vs Impure — Types & Solutions**

| Type | Side Effects? | Testable? | Solution |
|------|---------------|-----------|----------|
| **Pure** | No | Yes, easy | Business logic in use cases |
| **Impure** | I/O, mutable state | Mock deps | Inject; keep logic separate |
| **Referentially transparent** | Same input → same output | Yes | Prefer for calculations |

**Solution — Making Impure Testable:**
- Inject `AuthRepository` → mock in test
- Inject `Clock` for `DateTime.now()`
- Keep side effects at edges (repository, API)

---

## 3. Testable Code

- **Inject dependencies** — mock repositories, use cases
- **Pure business logic** — in use cases, not in UI
- **Small units** — one responsibility per class/function
- **Avoid static** — hard to mock
- **Avoid `DateTime.now()`** — inject clock

```dart
// Testable
class CreateSaleUseCase {
  final SaleRepository repo;
  CreateSaleUseCase(this.repo);
  Future<Either<Failure, Sale>> call(Sale sale) => repo.createSale(sale);
}
```

---

## 4. Synchronous vs Asynchronous

| Sync | Async |
|------|-------|
| Blocks until done | Returns immediately, completes later |
| `int x = compute();` | `Future<int> x = fetch();` |
| UI freezes during I/O | UI stays responsive |

**Dart:** `async`/`await` for async. Under the hood: Futures, event loop.

---

## 5. Event-Driven Architecture

Components communicate via events. Producers emit; consumers react. Loose coupling.

**Flutter Examples:**
- **BLoC:** `AuthEvent` → `AuthBloc` → `AuthState`
- **Streams:** `StreamController` broadcasts events
- **Event Bus:** app-wide events (e.g., `UserLoggedOut`)

---

# DART (ADVANCED)

## 1. final vs const vs late

| Keyword | Meaning | When |
|---------|---------|------|
| **final** | Set once (at runtime) | `final name = getName();` |
| **const** | Compile-time constant | `const pi = 3.14;` `const SizedBox()` |
| **late** | Lazily initialized, non-nullable | `late final x = expensive();` |

```dart
final a = DateTime.now(); // OK
const b = DateTime.now(); // Error
late String c; c = 'x';   // OK
```

### **final vs const vs late — Types & Solutions**

| Keyword | Compile-time? | Mutable? | Solution When to Use |
|---------|---------------|----------|----------------------|
| **final** | No | No (after init) | Runtime values: API response, `DateTime.now()` |
| **const** | Yes | No | Literals, `SizedBox()`, `EdgeInsets.zero` |
| **late** | No | Yes (before init) | Lazy init, nullable fields that you'll set |

**Solution — Performance:** Use `const` for widgets when possible → skips rebuild.

---

## 2. Isolates

**Definition:** Dart's concurrency model. Isolates are separate memory spaces — no shared state. Communicate via messages.

**When to Use:**
- CPU-heavy work (image processing, parsing large JSON)
- Keep UI thread free (60 FPS)

```dart
final result = await compute(parseLargeJson, jsonString);
```

**Don't use for:** Simple async I/O (use `async`/`await`).

### **Isolate Types — Detail**

| Type | Use | Solution |
|------|-----|----------|
| **Main isolate** | UI, event loop | Keep lightweight |
| **`compute()`** | One-off heavy task | Parse JSON, image processing |
| **`Isolate.spawn()`** | Long-running, two-way | Custom protocols, heavy computation |
| **`flutter_isolate`** | With plugins | When plugin needs main isolate |

**Solution — When to Use Isolates:**
- CPU-bound work > 16ms → Use `compute()` or isolate
- I/O-bound (network, file) → Use `async`/`await` only
- Shared state needed → Use `ReceivePort`/`SendPort` (copy data)

---

## 3. Dart Memory Management

- **Garbage collected** — no manual free
- **No shared mutable state** between isolates
- **References** — objects are referenced; when unreachable, GC collects

---

## 4. Event Loop

1. **Microtask queue** — `Future.microtask`, `scheduleMicrotask`
2. **Event queue** — I/O, timers, user input
3. Loop: Process microtasks → Process one event → Repeat

---

## 5. Future vs Stream vs async*

| Type | Values | Use Case |
|------|--------|----------|
| **Future** | Single value | API call, one-time async |
| **Stream** | Multiple values over time | WebSocket, file reading, user input |
| **async*** | Generator for Stream | `Stream<int> count() async* { for (var i = 0; i < 5; i++) yield i; }` |

### **Future vs Stream — Types & Solutions**

| Scenario | Use | Solution |
|----------|-----|----------|
| One API call | `Future` | `await api.getProduct(id)` |
| Multiple events | `Stream` | `Bloc` emits states; `StreamBuilder` |
| Generate sequence | `async*` | `Stream.periodic`; custom generators |
| Combine streams | `Stream` | `Rx.combineLatest`, `StreamZip` |
| Cancel needed | `Stream` | `StreamSubscription.cancel()` |

**Solution — Stream Best Practices:**
- Always cancel `StreamSubscription` in `dispose`
- Use `broadcast` only when multiple listeners
- Prefer `StreamController` for custom streams; close when done

---

## 6. Broadcast Streams

**Single-subscription:** One listener. Stops after cancel.
**Broadcast:** Multiple listeners. Doesn't stop.

**When:** Multiple widgets listening to same stream (e.g., connection status).

```dart
final controller = StreamController<int>.broadcast();
```

---

## 7. Mixins — Real Use Cases

**Definition:** Reusable code "mixed in" to classes. No inheritance.

```dart
mixin ValidationMixin {
  bool isValidEmail(String email) => email.contains('@');
}

class LoginForm with ValidationMixin {
  // has isValidEmail
}
```

**Flutter:** `SingleTickerProviderStateMixin` for AnimationController.

---

## 8. setState() Internals

1. Marks widget as dirty
2. Schedules a rebuild
3. Next frame: `build()` runs
4. Flutter diffs old vs new widget tree
5. Updates only changed render objects

**Problem:** Rebuilds entire subtree. Use `const`, `RepaintBoundary`, or state management (Bloc) to limit.

---

## 9. Null Safety

- `String` — non-nullable
- `String?` — nullable
- `!` — force unwrap (avoid if possible)
- `??` — default: `x ?? 'default'`
- `?.` — safe call: `user?.name`

---

## 10. JIT vs AOT in Dart

| Mode | When | Purpose |
|------|------|---------|
| **JIT** | Debug/development | Fast reload, hot reload |
| **AOT** | Release | Optimized, smaller, faster startup |

---

# FLUTTER (MID → SENIOR)

## Architecture

### MVVM vs MVC vs Clean Architecture

| Pattern | Structure | Flutter Fit |
|---------|-----------|-------------|
| **MVC** | Model-View-Controller | View = Widget, Controller = logic in widget |
| **MVVM** | Model-View-ViewModel | ViewModel = Bloc/ChangeNotifier, View = Widget |
| **Clean** | Domain → Data → Presentation | Use cases, repositories, entities. Pharmacy POS uses this. |

### Large-Scale App Structure (Pharmacy POS)

```
lib/
├── core/           # Router, theme, errors, DI
├── data/           # API, models, repository implementations
├── domain/         # Entities, repositories (abstract), use cases
└── presentation/   # Blocs, screens, widgets (per feature)
```

### Avoiding God Widgets

- Extract widgets (< 150 lines)
- One widget = one responsibility
- Use composition: `LoginForm`, `LoginButton`, `LoginHeader`

### State at Scale

- **Bloc/Riverpod** for app/feature state
- **Local state** for form fields, animations
- **Shared state** via providers, not prop drilling

### Provider vs Riverpod vs Bloc vs GetX

| Solution | Pros | Cons |
|----------|------|------|
| **Provider** | Simple, official | Boilerplate, no compile-time safety |
| **Riverpod** | Compile-safe, testable, no context | Learning curve |
| **Bloc** | Predictable, event-driven, testable | More boilerplate |
| **GetX** | Less code, fast | Magic, less explicit, ecosystem lock-in |

### When NOT to Use Provider

- Complex async flows → Bloc
- Need compile-time safety → Riverpod
- Global reactive state → Riverpod/Bloc

### **State Management — Solution: Which to Choose?**

| Need | Solution |
|------|----------|
| Simple app, few screens | Provider |
| Large app, testable, predictable | Bloc |
| Compile-safe, no context, testable | Riverpod |
| Fast prototyping, less boilerplate | GetX (trade-off: magic, lock-in) |
| Real-time, complex flows | Bloc + Streams |
| Multi-tenant, feature flags | Riverpod (scoped providers) |

**Pharmacy POS uses Bloc** — event-driven, testable, scales with Clean Architecture.

---

## Widgets & UI

### StatelessWidget vs StatefulWidget

- **Stateless:** Immutable, no internal state. Rebuilds when parent passes new data.
- **Stateful:** Has `State` object. Can hold mutable data, call `setState()`.

### Element Tree, Widget Tree, Render Tree

1. **Widget Tree** — Immutable configuration (what to build)
2. **Element Tree** — Mutable, holds state, links widgets to render objects
3. **Render Tree** — Layout and paint (actual pixels)

### 60 FPS

- ~16ms per frame
- Avoid heavy work on UI thread
- Use `compute()` for CPU work
- Optimize `build()` — avoid allocations, use `const`

### Large List Optimization

- `ListView.builder` — lazy, builds only visible items
- `SliverList` / `CustomScrollView`
- `RepaintBoundary` for complex items
- `AutomaticKeepAliveClientMixin` for tabs (sparingly)

### LayoutBuilder vs MediaQuery

- **LayoutBuilder:** Parent's constraints (width/height)
- **MediaQuery:** Screen size, padding, text scale, platform

### Keys — Types, Detail & Solutions

| Key Type | Identity By | Use Case | Solution When |
|----------|-------------|----------|---------------|
| **ValueKey** | Value (e.g., `id`) | List items with stable IDs | `ValueKey(product.id)` |
| **ObjectKey** | Object reference | Same value, different instances | Rare; prefer ValueKey |
| **UniqueKey** | Always unique | Force rebuild; animations | `UniqueKey()` — use sparingly |
| **GlobalKey** | Global identity | Access State, Form; scroll to widget | `GlobalKey<FormState>()` |
| **PageStorageKey** | Persist scroll position | Tab/List scroll restoration | `PageStorageKey('products')` |

**Solution — Key Selection:**
- List with IDs → `ValueKey(id)`
- Form validation → `GlobalKey<FormState>()`
- Animated list reorder → `ObjectKey` or `ValueKey`
- Avoid `UniqueKey` in `build()` — creates new key every rebuild!

---

## Performance

### Detecting Issues

- Flutter DevTools (Performance, CPU, Memory)
- `debugPrint` timings
- Profile mode (`flutter run --profile`)

### Jank Causes

- Heavy `build()` logic
- Synchronous I/O on UI thread
- Too many rebuilds
- Large images without caching

### Reducing Rebuilds

- `const` widgets
- `BlocBuilder` with `buildWhen`
- `Selector` (Provider)
- `RepaintBoundary`

### Image Optimization

- `cached_network_image`
- Appropriate resolution
- `Image.network` with `cacheWidth`/`cacheHeight`

### RepaintBoundary

Isolates repaint. Child repaints don't affect parent. Use for expensive widgets.

### Memory Leaks — Types & Solutions

| Type | Cause | Solution |
|------|-------|----------|
| **StreamSubscription** | Not cancelled | `subscription.cancel()` in `dispose` |
| **Timer** | Not cancelled | `timer.cancel()` in `dispose` |
| **Controller** | Not disposed | `controller.dispose()` for TextEditing, Animation |
| **Context** | Retained in async | Don't use `context` after `async` gap; use `mounted` check |
| **Listeners** | Not removed | `removeListener` in `dispose` |
| **GlobalKey** | Holds reference | Avoid in long-lived widgets |

**Solution — Dispose Pattern:**
```dart
@override
void dispose() {
  _subscription.cancel();
  _controller.dispose();
  super.dispose();
}
```

---

# MOBILE APP DEVELOPMENT

## Hot Restart vs Hot Reload — Types & Solutions

| Aspect | Hot Reload | Hot Restart |
|--------|------------|-------------|
| Speed | ~1 sec | ~5–10 sec |
| State | Preserved | Reset |
| Use | UI tweaks | Logic/init changes |
| Triggers | `r` in terminal | `R` (capital) or `flutter run` |

**Solution — When Each:**
- **Hot Reload:** Widget changes, styling, layout — state stays
- **Hot Restart:** `main()` changes, global init, static vars, new dependencies

## App Lifecycle (Android & iOS)

- **resumed** — foreground
- **inactive** — transitioning (e.g., call, app switcher)
- **paused** — background
- **detached** — app shut down

## Background Services

- **Android:** Foreground service, WorkManager
- **iOS:** Background modes (audio, location, fetch), limited
- **Flutter:** `workmanager`, platform channels

## Deep Linking

- **Android:** Intent filters
- **iOS:** Associated domains, URL schemes
- **Flutter:** `go_router`, `uni_links`

## APK vs AAB vs IPA

- **APK:** Android package (legacy)
- **AAB:** Android App Bundle — smaller, Play Store optimized
- **IPA:** iOS package

## Code Signing — Types & Solutions

| Platform | Components | Solution |
|----------|-------------|----------|
| **Android** | Keystore (.jks), key alias, passwords | Store keystore securely; use CI secrets |
| **iOS** | Certificates, Provisioning Profile, Entitlements | Apple Developer account; Xcode signing |
| **Flutter** | `flutter build` uses platform config | Configure in `android/app/build.gradle`, Xcode |

**Solution — Reduce App Size:**
- `--split-debug-info`; `--obfuscate`
- Use AAB (Android) — Play Store optimizes
- Compress images; use WebP
- Remove unused resources; tree-shake

## App Store Rejection Causes — Types & Solutions

| Type | Cause | Solution |
|------|-------|----------|
| **Crashes** | App crashes on launch/use | Test on real devices; fix before submit |
| **Privacy** | No policy; wrong data use | Add privacy policy; declare data collection |
| **Guidelines** | IAP for digital goods outside Apple | Use Apple IAP for digital; Stripe for physical |
| **Metadata** | Screenshots don't match app | Update screenshots; accurate description |
| **Permissions** | Unclear why permission needed | Explain in Info.plist; request when needed |
| **Design** | Doesn't follow HIG | Use Cupertino widgets; follow guidelines |

---

# BACKEND & API INTEGRATION

## REST & HTTP Methods

- **GET** — Read
- **POST** — Create
- **PUT** — Replace
- **PATCH** — Partial update
- **DELETE** — Remove

## PUT vs PATCH

- **PUT:** Replace entire resource
- **PATCH:** Update specific fields

## Idempotency

Same request, same result. GET, PUT, DELETE are idempotent. POST is not (creates new each time).

## Status Codes — Types & Solutions

| Code | Type | Meaning | Solution |
|------|------|---------|----------|
| **2xx** | Success | OK, Created | Proceed |
| **400** | Client | Bad Request (invalid input) | Validate input; show user error |
| **401** | Client | Unauthorized (no/invalid auth) | Refresh token or logout |
| **403** | Client | Forbidden (no permission) | Show "no access"; don't retry |
| **404** | Client | Not Found | Show "not found"; check URL |
| **429** | Client | Rate limited | Retry with backoff |
| **500** | Server | Internal error | Retry; show generic error |
| **502/503** | Server | Bad gateway / Unavailable | Retry; show "service unavailable" |

## Pagination Strategies — Types & Solutions

| Type | How | Use Case | Solution |
|------|-----|----------|----------|
| **Offset** | `?page=2&limit=20` | Simple lists | Easy; slow for large offsets |
| **Cursor** | `?cursor=abc&limit=20` | Infinite scroll | Efficient; consistent with real-time |
| **Keyset** | `?after_id=123` | Sorted lists | No skip; good for large datasets |

**Pharmacy POS:** `AppConfig.defaultPageSize = 20` — use cursor for products/sales.

---

## GraphQL vs REST

| Aspect | REST | GraphQL |
|--------|------|---------|
| **Endpoints** | Many (per resource) | One |
| **Over/under-fetch** | Common | Client specifies fields |
| **Caching** | HTTP cache | Custom (Apollo, etc.) |
| **Learning** | Simpler | Steeper |

**Solution — When GraphQL:** Complex data needs; mobile (reduce payload); multiple clients with different needs.

---

## JWT vs OAuth

- **JWT:** Token format. Self-contained. Stateless.
- **OAuth:** Protocol. Delegated authorization. Can use JWT as token.

## Token Expiration

- Short-lived access token
- Refresh token for new access token
- Interceptor: on 401 → refresh → retry

### **API Integration — Types & Solutions**

| Problem | Type | Solution |
|---------|------|----------|
| **401 Unauthorized** | Token expired/invalid | Refresh token → retry request; if refresh fails → logout |
| **403 Forbidden** | No permission | Show user message; don't retry |
| **500 Server Error** | Backend failure | Retry with backoff; show generic error |
| **Network timeout** | No connection | Retry; offline queue; show "Check connection" |
| **Rate limit (429)** | Too many requests | Exponential backoff; respect Retry-After header |

**Solution — Dio Interceptor Example:**
```dart
// On 401: refresh token, retry, or logout (Dio 5.x)
dio.interceptors.add(QueuedInterceptor(
  onError: (e, h) async {
    if (e.response?.statusCode == 401) {
      final refreshed = await authRepo.refreshToken();
      if (refreshed) { /* retry request */ } else { /* logout */ }
    }
    h.next(e);
  },
));
```

---

# FIREBASE

## Auth: Firebase vs Custom

- **Firebase:** Fast, social login, phone auth. Less control.
- **Custom:** Full control, own backend. More work.

## Firestore vs Realtime DB

- **Firestore:** Documents, queries, offline. Better for most apps.
- **Realtime:** JSON tree, real-time sync. Simpler, cheaper for small data.

## Firestore Indexing

- Composite indexes for complex queries
- Auto-created for simple queries
- Define in `firestore.indexes.json`

## Cold Starts (Cloud Functions)

First invocation after idle is slow. Mitigate: min instances, keep-warm ping.

## When NOT to Use Firebase

- Complex relational data
- Need SQL, transactions
- Vendor lock-in concerns
- Cost at scale

### **Firebase — Types & Solutions**

| Component | Types | Solution |
|-----------|-------|----------|
| **Auth** | Email, Phone, Social, Anonymous | Use Anonymous for guest; migrate to permanent on sign-up |
| **Firestore** | Document, Collection | Denormalize for reads; batch writes for consistency |
| **FCM** | Data, Notification | Data: handle in app; Notification: system tray |
| **Cloud Functions** | HTTP, Firestore trigger, Auth trigger | Use min instances to reduce cold starts |
| **Storage** | Images, files | Use `cacheControl`; resize before upload |

**Solution — Firestore Rules:**
```javascript
// Multi-tenant: ensure tenant_id matches
match /products/{id} {
  allow read, write: if request.auth != null 
    && resource.data.tenant_id == request.auth.token.tenant_id;
}
```

---

# DATABASES

## SQL vs NoSQL

| SQL | NoSQL |
|-----|-------|
| Tables, relations | Documents, key-value, graph |
| ACID | Eventually consistent (often) |
| Schema | Schema-less/flexible |

## Normalization

Reduce redundancy. 1NF, 2NF, 3NF. Trade-off: more joins vs. redundancy.

## Indexing

- **Pros:** Faster reads
- **Cons:** Slower writes, storage

## Offline-First

- Local DB (SQLite, Hive)
- Sync when online
- Conflict resolution (last-write-wins, CRDTs, etc.)

### **Database Types & Solutions**

| Type | Use Case | Solution |
|------|----------|----------|
| **SQL (SQLite)** | Relations, ACID, complex queries | Pharmacy POS: products, sales, inventory |
| **NoSQL (Firestore)** | Flexible schema, real-time | Chat, activity feeds |
| **Key-Value (Hive)** | Cache, simple storage | Settings, tokens |
| **Graph** | Relationships (social, recommendations) | Rare in mobile |

**Solution — Slow Query:**
1. Add index on filter/sort columns
2. Limit result set (pagination)
3. Avoid N+1 (batch/join)
4. Profile with `EXPLAIN QUERY PLAN`

**Solution — Offline-First Sync:**
1. Local DB as source of truth
2. Queue writes when offline
3. Sync on reconnect
4. Conflict: last-write-wins or merge (CRDT)

---

# SECURITY

## Sensitive Data Storage

- **Android:** EncryptedSharedPreferences, Keystore
- **iOS:** Keychain
- **Flutter:** `flutter_secure_storage`

## Encryption

- **At rest:** Data on disk encrypted
- **In transit:** TLS/HTTPS

## Certificate Pinning

Pin server certificate to prevent MITM. Use for high-security APIs.

## API Keys

- Never in source code
- Use env vars, CI secrets
- Backend proxy for sensitive keys

## OWASP Mobile Top 10 — Types & Solutions

| # | Vulnerability | Solution |
|---|---------------|----------|
| M1 | Improper platform usage | Follow platform security guidelines |
| M2 | Insecure data storage | `flutter_secure_storage`; encrypt sensitive data |
| M3 | Insecure communication | HTTPS; certificate pinning for high-security |
| M4 | Insecure authentication | Strong auth; token rotation; biometric |
| M5 | Insufficient cryptography | Use AES-256; avoid weak algorithms |
| M6 | Insecure authorization | Check permissions server-side; RBAC |
| M7 | Client code quality | Input validation; avoid injection |
| M8 | Code tampering | Obfuscation; integrity checks |
| M9 | Reverse engineering | Obfuscation; no secrets in app |
| M10 | Extraneous functionality | Remove debug code; disable dev features |

### **Security Types & Solutions**

| Vulnerability | Type | Solution |
|---------------|------|----------|
| **Insecure storage** | Plain text secrets | `flutter_secure_storage`; Keychain/Keystore |
| **MITM** | Intercepted traffic | HTTPS; certificate pinning for high-security |
| **Reverse engineering** | Decompilation | Obfuscation (`--obfuscate`); avoid hardcoded secrets |
| **Token theft** | Stolen tokens | Short expiry; refresh rotation; secure storage |
| **Insecure comms** | No TLS | Always HTTPS; validate certificates |

**Solution — Secure Token Storage:**
```dart
// Use flutter_secure_storage (Keychain/Keystore)
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
// Never: SharedPreferences for tokens
```

---

# DEVOPS / CI-CD

## Flutter CI/CD Pipeline

1. Checkout
2. Setup Flutter
3. `flutter pub get`
4. `flutter analyze`
5. `flutter test`
6. Build (APK/AAB/IPA)
7. Deploy (Store, Firebase App Distribution)

## Environment Variables

- `--dart-define` for compile-time
- `.env` files (not committed)
- CI secrets for keys

## Rollback

- Store previous build
- Revert release in Play Console / App Store Connect
- Feature flags to disable problematic features

---

# SYSTEM DESIGN

## Multi-Tenant SaaS (Pharmacy POS)

- **Tenant ID** in all requests (`tenant_id` in `AppConfig`)
- Row-level security: filter by `tenant_id`
- Shared infra, isolated data
- Subscription per tenant

## Offline-First

- Local DB as source of truth
- Queue writes when offline
- Sync + conflict resolution when online

## Feature Flags

- Remote config (Firebase, LaunchDarkly)
- Enable/disable per user, cohort, percentage

### **System Design — Solution Templates**

| Design | Key Components | Solution |
|--------|-----------------|----------|
| **Food Delivery** | Users, Restaurants, Orders, Riders, Real-time location | Microservices; WebSocket for tracking; Queue for orders |
| **Chat App** | Messages, Rooms, Presence, Push | WebSocket/Firestore; offline sync; FCM for push |
| **Multi-tenant SaaS** | Tenants, RBAC, Billing | `tenant_id` in all tables; row-level security; Stripe per tenant |
| **Offline-First** | Local DB, Sync, Conflict | SQLite/Hive; queue writes; last-write-wins or CRDT |
| **Role-Based Access** | Roles, Permissions, Resources | RBAC table; check permission at API + UI |
| **Real-Time Updates** | WebSocket, Server-Sent Events | Firestore listeners; Socket.io; polling fallback |

---

# SOFT SKILLS

## Conflict Resolution

- Listen first
- Focus on problem, not person
- Seek common ground
- Escalate if needed

## Mentoring Juniors

- Pair programming
- Code reviews with explanation
- Small, incremental tasks
- Encourage questions

## Code Review Feedback

- Be specific, constructive
- Explain "why"
- Praise good practices
- Suggest, don't demand

## Leadership vs Management

- **Leadership:** Vision, influence, inspiration
- **Management:** Planning, execution, resources

### **Soft Skills — Solution Templates**

| Situation | Solution Template |
|-----------|-------------------|
| **Conflict** | Listen → Acknowledge → Find common goal → Propose compromise → Escalate if needed |
| **Mentoring** | Pair program → Explain why → Give small tasks → Review with feedback → Encourage questions |
| **Tight deadline** | Prioritize → Cut scope (MVP) → Communicate early → Document trade-offs |
| **Unclear requirements** | Ask clarifying questions → Document assumptions → Get sign-off → Iterate |
| **Code review** | Be specific ("Use const here") → Explain why → Praise good parts → Suggest, don't demand |
| **Prioritize tasks** | Urgent + Important first → Eisenhower matrix → Align with business goals |

---

# SCENARIO / BEHAVIORAL

## App Crashes in Production

**Solution — Step-by-Step:**
1. **Triage:** Check crash rate, affected users, platform
2. **Reproduce:** Use crash logs (Firebase Crashlytics, Sentry), stack trace, device/OS
3. **Fix:** Root cause fix; add null check/guard if needed
4. **Test:** Unit + integration; test on same device/OS
5. **Release:** Hotfix or feature flag off
6. **Post-mortem:** What caused it? How to prevent? Add tests/monitoring

**Types of Crashes:**
| Type | Cause | Solution |
|------|-------|----------|
| Null pointer | Null safety gap | Add `?`, `!`, or guard |
| Out of memory | Large images, leaks | Profile; fix leaks; resize images |
| Platform-specific | iOS/Android difference | Test both; use platform channels correctly |
| Race condition | Async timing | Use proper async; avoid shared mutable state |

---

## Client Wants Change Near Deadline

**Solution — Template:**
1. **Assess:** Scope, risk, timeline impact
2. **Communicate:** "This adds X days; we'd need to cut Y or push deadline"
3. **Propose:** Phased release (MVP now, rest later); or swap scope (drop Z for this)
4. **Document:** Written agreement; update backlog
5. **Execute:** Prioritize; communicate progress

---

## Poor Performance on Low-End Devices

**Solution — Checklist:**
1. **Profile:** Run on low-end device; use Flutter DevTools
2. **Reduce allocations:** Avoid creating objects in `build()`; use `const`
3. **Simplify UI:** Fewer widgets; `RepaintBoundary` for heavy parts
4. **Lazy load:** `ListView.builder`; load images on demand
5. **Lower assets:** Smaller images; optional "lite" mode
6. **Isolates:** Move heavy work off UI thread

---

## Disagree with Architect

**Solution — Approach:**
1. **Understand:** Ask why; get full context
2. **Data:** Present alternatives with pros/cons
3. **Discuss:** Team forum; not in hallway
4. **Decide:** Architect/lead decides; support decision
5. **Revisit:** If evidence changes, raise again with data

---

## How Do You Estimate Tasks?

**Solution — Technique:**
1. **Break down:** Small tasks (< 1 day)
2. **Add buffer:** 20–30% for unknowns
3. **Historical:** Use past similar tasks
4. **Three-point:** Optimistic, realistic, pessimistic → average
5. **Communicate:** "2–3 days" not "2 days" when uncertain

---

# TRICK QUESTIONS

## Why Flutter Isn't Always Best

- Heavy apps (large binary)
- Platform-specific needs (complex native APIs)
- Performance-critical (games, video)
- Team expertise (native devs)

## When to Choose Native

- Deep platform integration
- Maximum performance
- Existing native codebase
- App Store policies (e.g., past rejections)

## Platform Independence?

- Mostly yes for UI and logic
- Plugins can be platform-specific
- Some features need platform channels
- Design guidelines differ (Material vs Cupertino)

## Trade-offs

- Larger app size
- Skia rendering (not native widgets)
- Dependency on Dart/Flutter ecosystem
- Learning curve for team

### **Trick Questions — Solution: How to Answer**

| Question | Solution — Answer Structure |
|----------|-----------------------------|
| **Why not Flutter?** | "For X (e.g., heavy games, deep native APIs), native is better because Y. Flutter excels at Z." |
| **When native?** | "When we need platform-specific features Flutter doesn't support well, or performance is critical." |
| **Platform independent?** | "Mostly yes for UI and logic. Plugins and platform channels bridge gaps. Design differs (Material/Cupertino)." |
| **Trade-offs?** | "Larger binary, Skia not native widgets, ecosystem dependency. We gain single codebase, fast iteration." |

---

## Document Summary

| Section | Coverage |
|---------|----------|
| **Core** | OOP, SOLID, Design Patterns, DI — with types, solutions |
| **Advanced** | Immutability, Pure functions, Testable code — with solutions |
| **Dart** | final/const/late, Isolates, Streams — types & when to use |
| **Flutter** | Architecture, State, Keys, Performance — solution guides |
| **Mobile** | Lifecycle, Deep linking, APK/AAB — solutions |
| **Backend** | REST, Status codes, Token handling — solution templates |
| **Firebase, DB, Security** | Types, solutions, code examples |
| **DevOps, System Design** | Pipeline, rollback, design templates |
| **Soft Skills, Behavioral** | Solution templates for interviews |

---

*Document version: 2.0 | Pharmacy POS Project | Senior Flutter Developer Reference | Versatile, detailed, with types and solutions*
