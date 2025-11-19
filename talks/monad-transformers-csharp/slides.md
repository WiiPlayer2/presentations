---
theme: default
# apply any unocss classes to the current slide
class: 'text-center'
# transition: slide-left
title: Monad Transformers in C#
mdc: true
---

# Monad Transformers in C#

Über Monaden, Higher Order Generics und die Grenzen des C#-Typsystems

---

# Wer bin ich?

---

# Motivation - Monaden

<v-clicks>

```csharp
record Monad<T>(...);
{
  public static Monad<T> Return(T value) => ...;

  public Monad<TOut> Bind<TOut>(Func<T, Monad<TOut>> fn) => ...;
}
```

\+ 3 Gesetze (https://wiki.haskell.org/Monad_laws)

</v-clicks>

---

# Motivation - Monaden

```csharp
record Lst<T>(IReadOnlyList<T> Items)
{
  public static Lst<T> Return(T value) =>
    new([value]);

  public Lst<TOut> Bind<TOut>(Func<T, Lst<TOut>> fn) =>
    new(Items.SelectMany(x => fn(x).Items).ToList());
}
```

---

# Motivation - Higher Order Generics

<v-click>

````md magic-move
```csharp
interface IMonad<T>
{
  static abstract IMonad<T> Return(T value);

  IMonad<TOut> Bind<TOut>(Func<T, IMonad<TOut>> fn);
}
```
```csharp
interface IMonad<TMonad, T>
{
  static abstract TMonad<T> Return(T value);

  TMonad<TOut> Bind<TOut>(Func<T, TMonad<TOut>> fn);
}
```
````

</v-click>

---

# Motivation - Monadentransformer

<v-click>

```csharp
static TMonad<Lst<TOut>> BindT<TMonad, T, TOut>(
  TMonad<Lst<T>> ma,
  Func<T, TMonad<Lst<T>>> fn
) => ...
```

</v-click>

---

# Ziel

<v-clicks depth="2">

- Wir wollen ohne großen Aufwand in der Lage sein, Monadentransformer zu definieren.
- Die Monadentransformer sollen auf alle Monaden anwendbar sein.
  - Das heißt auch, zur Design-Time unbekannte Monaden.
- Monaden sollen mehrfach hintereinander transformiert werden können.

</v-clicks>

---

# C#'s Grenzen

<v-clicks>

- C# unterstützt keine arbiträren Nested Generics bzw. Type Constructors.
- Typ-Inferenz ist nur auf direkte Typ-Assoziationen beschränkt.

</v-clicks>

---

# Umsetzung

<v-click>

````md magic-move
```csharp
record Lst<T>(IReadOnlyList<T> Items)
{
  public static Lst<T> Return(T value) => ...;

  public Lst<TOut> Bind<TOut>(Func<T, Lst<TOut>> fn) => ...;
}
```
```csharp
record Lst<T>(IReadOnlyList<T> Items);

record Id<T>(T Value)
{
  public static Id<T> Return(T value) => new(value);

  public Id<TOut> Bind<TOut>(Func<T, Id<TOut>> fn) => new(fn(Value));
}
```
```csharp
record Lst<T>(IReadOnlyList<T> Items);
record Id<T>(T Value);

static class LstT
{
  public static Id<Lst<TOut>> Bind<T, TOut>(
    this Id<Lst<T>> ma,
    Func<T, Id<Lst<TOut>>> fn
  ) =>
    new(ma.Value.Bind(x => fn(x).Value));
}
```
```csharp
record Lst<T>(IReadOnlyList<T> Items);
record Id<T>(T Value);

static class LstT
{
  public static Id<Lst<TOut>> Bind<T, TOut>(
    this Id<Lst<T>> ma,
    Func<T, Id<Lst<TOut>>> fn
  ) =>
    ma.Bind(xs => xs.Value.Aggregate(
      Id<Lst<TOut>>.Return(new([])),
      (acc, cur) => acc
          .Bind(ys => fn(cur)
          .Map(ys_ => new Lst<TOut>([..ys.Value, ..ys_.Value])))
    ));
}
```
```csharp
record Lst<T>(IReadOnlyList<T> Items);
record Id<T>(T Value);

static class LstT
{
  public static IMonad<Lst<TOut>> Bind<T, TOut>(
    this IMonad<Lst<T>> ma,
    Func<T, Id<IMonad<TOut>>> fn
  ) =>
    ma.Bind(xs => xs.Value.Aggregate(
      ma.Return(new([])),
      (acc, cur) => acc
          .Bind(ys => fn(cur)
          .Map(ys_ => new Lst<TOut>([..ys.Value, ..ys_.Value])))
    ));
}
```
```csharp
record Lst<T>(IReadOnlyList<T> Items);
record Id<T>(T Value);

[MonadTransformer(typeof(Lst<>))]
static class LstT
{
  public static IMonad<Lst<TOut>> Bind<T, TOut>(
    this IMonad<Lst<T>> ma,
    Func<T, Id<IMonad<TOut>>> fn
  ) =>
    ma.Bind(xs => xs.Value.Aggregate(
      ma.Return(new([])),
      (acc, cur) => acc
          .Bind(ys => fn(cur)
          .Map(ys_ => new Lst<TOut>([..ys.Value, ..ys_.Value])))
    ));
}
```
```csharp
record Lst<T>(IReadOnlyList<T> Items);
record Id<T>(T Value);

[MonadTransformer(typeof(Lst<>))]
static class LstT;

[Transform(typeof(Id<>), typeof(Lst))]
partial static class IdLst;
```
````

</v-click>

---
layout: section
---

# Demo

---

# Zukunft und Wünsche

<v-clicks>

- Eine Bibliothek mit der man domänenunabhängige Higher Order Generics erstellen und benutzen kann
- Das Typ-System von C# könnte mehr, but doesn't. 🤷
- Ich wünsche mir First-Class-Support von Higher Order Generics in C#

</v-clicks>

---
layout: image-left
image: https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.PAq1g9lE92gIeyZmVLa6jgHaHY%3Fpid%3DApi&f=1&ipt=86cc5a28be669acc3bfc7584275add48e621043bb52611de106f31c00f5a0bf2&ipo=images
---

- https://github.com/bluehands/Funicular-Switch

---
layout: center
---

thx

