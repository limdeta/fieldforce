# BLoC Quick Start Guide 🚀

**Мини-гайд для веб-разработчиков: быстро вкатиться в BLoC и начать делать фичи**

## 🎯 Что такое BLoC и зачем он нужен?

**BLoC** (Business Logic Component) — это официальный паттерн управления состоянием от команды Google для Flutter. Если ты работал с Redux, MobX или Vuex — концепция покажется знакомой.

### 🏗️ Откуда пришел BLoC?

Паттерн появился в 2018 году на Google I/O как ответ на проблемы масштабирования Flutter-приложений. Команда Flutter заметила, что разработчики пишут неструктурированный код, смешивая UI логику с бизнес-логикой в StatefulWidget'ах.

**Основная идея:** отделить бизнес-логику от UI настолько сильно, чтобы один и тот же код мог работать в Flutter, AngularDart и даже веб-приложениях.

### 🎨 Архитектурная философия

BLoC строится на трех китах:
1. **Streams** — асинхронные потоки данных (как RxJS)
2. **Events** — действия пользователя (клики, ввод текста)  
3. **States** — снимки состояния UI в конкретный момент

```
UI отправляет Events → BLoC обрабатывает → UI получает новые States
```

### 🔥 Какие проблемы решает BLoC?

#### В веб-разработке ты знаешь эти боли:
- **Спагетти-код**: логика размазана по компонентам
- **Дублирование**: одну и ту же логику пишешь в разных местах
- **Тестирование**: сложно тестировать UI вместе с логикой
- **Масштабирование**: новые фичи ломают старые

#### BLoC решает это:
✅ **Separation of Concerns** — UI занимается только отображением  
✅ **Single Source of Truth** — одно место для состояния фичи  
✅ **Testability** — бизнес-логика тестируется отдельно от UI  
✅ **Predictability** — четкий flow: Event → Logic → State  
✅ **Scalability** — новые фичи не влияют на старые

### 🚀 Почему Google рекомендует именно BLoC?

1. **Переиспользование кода**: один BLoC работает на Android, iOS, Web
2. **Официальная поддержка**: команда Flutter поддерживает библиотеку
3. **Зрелость экосистемы**: dev tools, testing utilities, документация
4. **Performance**: оптимизированные rebuilds только нужных виджетов
5. **Debugging**: четкий trace событий и состояний

### 🎭 Сравнение с другими подходами

**Без BLoC (StatefulWidget):**
```
UI ← Logic + Data + Network ← Database
     (всё в одном месте)
```

**С BLoC:**
```
UI ← BLoC ← UseCase ← Repository ← Database
     ↑        ↑         ↑
   только   бизнес-   данные
    UI      логика
```

### 🏛️ Архитектурные слои в нашем проекте

```
Presentation Layer (UI)
    ↓ Events
Business Logic Layer (BLoC + UseCases)  
    ↓ Repository calls
Data Layer (Repositories + DataSources)
    ↓ Network/Database calls
External APIs / Local Database
```

**Каждый слой знает только о слое ниже** — это делает код модульным и тестируемым.

## 📁 Структура файлов (наш пример: SalesRepHomePage)

```
lib/app/presentation/pages/sales_rep_home/
├── bloc/
│   ├── sales_rep_home_event.dart    # События (что может произойти)
│   ├── sales_rep_home_state.dart    # Состояния (как выглядит UI)
│   └── sales_rep_home_bloc.dart     # Логика (что делать с событиями)
└── sales_rep_home_page.dart         # UI компонент
```

## ⚡ Быстрый старт: Практические примеры

### 🎮 Как работает BLoC на практике

Представь: у тебя есть экран со списком товаров. Пользователь может:
- Загрузить список 
- Отфильтровать по категории
- Добавить в корзину
- Обновить список

**Без BLoC:** вся логика в StatefulWidget, setState() везде, боль и страдания.

**С BLoC:** каждое действие = Event, каждое состояние экрана = State, вся логика в одном месте.

### 🏗️ Три кита BLoC'а

#### 1. Events — что пользователь может сделать

```dart
// sales_rep_home_event.dart
abstract class SalesRepHomeEvent extends Equatable {
  const SalesRepHomeEvent();
}

class SalesRepHomeInitializeEvent extends SalesRepHomeEvent {
  final shop.Route? preselectedRoute;
  const SalesRepHomeInitializeEvent({this.preselectedRoute});
  @override
  List<Object?> get props => [preselectedRoute];
}

class LoadUserRoutesEvent extends SalesRepHomeEvent {
  const LoadUserRoutesEvent();
  @override
  List<Object> get props => [];
}

class SelectRouteEvent extends SalesRepHomeEvent {
  final shop.Route route;
  const SelectRouteEvent(this.route);
  @override
  List<Object> get props => [route];
}
```

**Принцип:** Каждый Event — это намерение пользователя. Как кнопки на пульте от телевизора.

#### 2. States — как выглядит экран

```dart
// sales_rep_home_state.dart
abstract class SalesRepHomeState extends Equatable {
  const SalesRepHomeState();
}

class SalesRepHomeInitial extends SalesRepHomeState {
  const SalesRepHomeInitial();
  @override
  List<Object> get props => [];
}

class SalesRepHomeLoading extends SalesRepHomeState {
  const SalesRepHomeLoading();
  @override
  List<Object> get props => [];
}

class SalesRepHomeLoaded extends SalesRepHomeState {
  final shop.Route? currentRoute;
  final List<shop.Route> availableRoutes;
  final bool isMapVisible;
  
  const SalesRepHomeLoaded({
    this.currentRoute,
    required this.availableRoutes,
    this.isMapVisible = false,
  });

  // Копирование с изменениями (immutable pattern)
  SalesRepHomeLoaded copyWith({
    shop.Route? currentRoute,
    List<shop.Route>? availableRoutes,
    bool? isMapVisible,
  }) {
    return SalesRepHomeLoaded(
      currentRoute: currentRoute ?? this.currentRoute,
      availableRoutes: availableRoutes ?? this.availableRoutes,
      isMapVisible: isMapVisible ?? this.isMapVisible,
    );
  }

  @override
  List<Object?> get props => [currentRoute, availableRoutes, isMapVisible];
}

class SalesRepHomeError extends SalesRepHomeState {
  final String message;
  const SalesRepHomeError(this.message);
  @override
  List<Object> get props => [message];
}
```

**Принцип:** State — это снимок экрана в конкретный момент. Как кадры в фильме.

#### 3. BLoC — мозг операции

```dart
// sales_rep_home_bloc.dart
class SalesRepHomeBloc extends Bloc<SalesRepHomeEvent, SalesRepHomeState> {
  final LoadUserRoutesUseCase _loadUserRoutesUseCase = GetIt.instance<LoadUserRoutesUseCase>();

  SalesRepHomeBloc() : super(const SalesRepHomeInitial()) {
    // Регистрируем обработчики событий
    on<SalesRepHomeInitializeEvent>(_onInitialize);
    on<LoadUserRoutesEvent>(_onLoadUserRoutes);
    on<SelectRouteEvent>(_onSelectRoute);
  }

  // Обработчик инициализации
  Future<void> _onInitialize(
    SalesRepHomeInitializeEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    emit(const SalesRepHomeLoading());
    
    try {
      final result = await _loadUserRoutesUseCase.execute();
      
      result.fold(
        (failure) => emit(SalesRepHomeError(failure.toString())),
        (routes) => emit(SalesRepHomeLoaded(
          availableRoutes: routes,
          currentRoute: event.preselectedRoute,
        )),
      );
    } catch (e) {
      emit(SalesRepHomeError('Ошибка загрузки: $e'));
    }
  }

  // Обработчик выбора маршрута
  Future<void> _onSelectRoute(
    SelectRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is SalesRepHomeLoaded) {
      emit(currentState.copyWith(currentRoute: event.route));
    }
  }
}
```

## 🖥️ UI компонент - как использовать BLoC

```dart
// sales_rep_home_page.dart
class SalesRepHomePage extends StatelessWidget {
  final shop.Route? selectedRoute;

  const SalesRepHomePage({super.key, this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Создаем BLoC и сразу инициализируем
      create: (context) => SalesRepHomeBloc()
        ..add(SalesRepHomeInitializeEvent(preselectedRoute: selectedRoute)),
      child: const SalesRepHomeView(),
    );
  }
}

class SalesRepHomeView extends StatelessWidget {
  const SalesRepHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SalesRepHomeBloc, SalesRepHomeState>(
        // Слушаем изменения состояния для side effects
        listener: (context, state) {
          if (state is SalesRepHomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        // Строим UI в зависимости от состояния
        builder: (context, state) {
          if (state is SalesRepHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SalesRepHomeLoaded) {
            return Column(
              children: [
                // Список маршрутов
                Expanded(
                  child: ListView.builder(
                    itemCount: state.availableRoutes.length,
                    itemBuilder: (context, index) {
                      final route = state.availableRoutes[index];
                      return ListTile(
                        title: Text(route.name),
                        selected: state.currentRoute?.id == route.id,
                        onTap: () {
                          // Отправляем событие в BLoC
                          context.read<SalesRepHomeBloc>().add(
                            SelectRouteEvent(route),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Кнопки действий
                if (state.currentRoute != null)
                  ElevatedButton(
                    onPressed: () {
                      context.read<SalesRepHomeBloc>().add(
                        const BuildRouteEvent(),
                      );
                    },
                    child: const Text('Построить маршрут'),
                  ),
              ],
            );
          }
          
          return const Center(child: Text('Что-то пошло не так'));
        },
      ),
    );
  }
}
```

**Принцип:** BLoC получает Event, решает что делать, и выплевывает новый State. Как редьюсер в Redux.

## 🛠️ Дополнительные концепции

### UseCase Pattern — бизнес-логика отдельно

Чтобы BLoC не раздувался, сложную логику выносим в UseCases:

```dart
// load_user_routes_usecase.dart
class LoadUserRoutesUseCase {
  final RouteRepository _routeRepository;

  LoadUserRoutesUseCase(this._routeRepository);

  Future<Either<Failure, List<shop.Route>>> execute() async {
    try {
      final session = GetIt.instance<AppSessionService>();
      
      if (session.currentSession == null) {
        return Left(GeneralFailure('Пользователь не авторизован'));
      }

      final routes = await _routeRepository
          .watchEmployeeRoutes(session.currentSession!.appUser.employee)
          .first;

      // Сортируем по дате
      routes.sort((a, b) => (a.date ?? DateTime.now())
          .compareTo(b.date ?? DateTime.now()));

      return Right(routes);
    } catch (e) {
      return Left(GeneralFailure('Ошибка загрузки маршрутов: $e'));
    }
  }
}
```

**Принцип:** UseCase = один конкретный бизнес-сценарий. Как микросервис, но внутри приложения.

### Dependency Injection — связываем всё вместе

Регистрируем зависимости в одном месте:

```dart
// service_locator.dart
void setupUseCases() {
  getIt.registerLazySingleton<LoadUserRoutesUseCase>(
    () => LoadUserRoutesUseCase(getIt<RouteRepository>()),
  );
}
```

**Принцип:** GetIt — это контейнер зависимостей. Как DI в Angular или Spring.

## 🎯 Практический workflow

### Пошагово: как добавить новую фичу

1. **Анализируй требования**
   - Что пользователь может делать? → Events
   - Как должен выглядеть экран? → States
   - Какая бизнес-логика нужна? → UseCases

2. **Создавай файлы в правильном порядке**
   - Events (быстро)
   - States (подумай о всех случаях)
   - UseCases (если логика сложная)
   - BLoC (связываешь всё)
   - UI (BlocProvider + BlocConsumer)

3. **Тестируй по частям**
   - UseCase отдельно
   - BLoC отдельно  
   - UI с моками

### Чек-лист для code review

✅ События описывают намерения пользователя  
✅ Состояния покрывают все случаи (loading, success, error)  
✅ BLoC не знает о UI (нет BuildContext)  
✅ UI не знает о Repository (только через BLoC)  
✅ Всё immutable (const конструкторы, copyWith)  
✅ Зависимости инжектятся через GetIt

## 🔥 Частые паттерны и трюки

### Отправить событие из UI

### Отправить событие
```dart
context.read<MyBloc>().add(SomeEvent());
```

### Слушать состояние в UI
```dart
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state is Loading) return CircularProgressIndicator();
    if (state is Loaded) return Text(state.data);
    return Text('Error');
  },
)
```

### Side effects (навигация, снэкбары)
```dart
BlocListener<MyBloc, MyState>(
  listener: (context, state) {
    if (state is Error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: MyWidget(),
)
```

### И то и другое
```dart
BlocConsumer<MyBloc, MyState>(
  listener: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
)
```

### Продвинутые техники

**Условные rebuild'ы:**
```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) => previous.data != current.data,
  builder: (context, state) => Text(state.data),
)
```

**Композиция BLoC'ов:**
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
    BlocProvider<ProductsBloc>(create: (context) => ProductsBloc()),
  ],
  child: MyApp(),
)
```

**Реагирование на изменения в другом BLoC'е:**
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthLoggedOut) {
      context.read<CartBloc>().add(ClearCart());
    }
  },
  child: MyWidget(),
)
```

## 🚨 Важные правила и подводные камни

### DO ✅
- **События immutable**: всегда используй `const` конструкторы
- **Состояния immutable**: копируй через `copyWith()`, никогда не мутируй
- **Один BLoC = одна фича**: не делай God Object'ы  
- **BLoC не знает о UI**: никаких BuildContext или Navigator
- **Называй понятно**: `LoadUserDataEvent`, не `ButtonPressedEvent`
- **Обрабатывай все ошибки**: always emit error states

### DON'T ❌
- **Не сохраняй Emitter**: используй только в обработчиках событий
- **Не делай sync операции**: BLoC предназначен для async
- **Не смешивай UI логику**: анимации и навигация остаются в UI
- **Не забывай про dispose**: закрывай streams и subscriptions
- **Не игнорируй типизацию**: используй сильную типизацию Dart

### 🐛 Частые ошибки новичков

1. **Мутирование state'а**
   ```dart
   // ❌ Плохо
   state.items.add(newItem);
   
   // ✅ Хорошо  
   state.copyWith(items: [...state.items, newItem])
   ```

2. **Обработка async без await**
   ```dart
   // ❌ Плохо
   repository.getData(); // забыл await
   
   // ✅ Хорошо
   final data = await repository.getData();
   ```

3. **Emit в неправильном месте**
   ```dart
   // ❌ Плохо - вне обработчика события
   void someMethod() {
     emit(SomeState());
   }
   
   // ✅ Хорошо - только в обработчике
   Future<void> _onSomeEvent(SomeEvent event, Emitter emit) async {
     emit(SomeState());
   }
   ```

## 🎉 Заключение

BLoC — это не просто библиотека, это архитектурная философия. Он заставляет думать о приложении как о потоке данных, а не как о набоpe виджетов.

**Главные преимущества:**
- 📏 **Предсказуемость**: всегда понятно, где что происходит
- 🧪 **Тестируемость**: каждый слой тестируется отдельно  
- 🔄 **Переиспользование**: один BLoC для mobile и web
- 🚀 **Скорость разработки**: меньше багов, больше фич
- 👥 **Командная работа**: стандартная структура для всех

Сейчас можешь копировать `SalesRepHomePage` и делать новые фичи. А вечером почитай [официальную документацию](https://bloclibrary.dev/) — там много крутых техник! 😉

**P.S.** Если застрял или что-то непонятно — не стесняйся спрашивать. BLoC кажется сложным первые пару дней, потом становится естественным как дыхание.
