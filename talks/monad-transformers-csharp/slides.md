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
layout: image-right
image: ./me.jpg
class: text-middle
---

# Wer bin ich?

<v-clicks depth="2">

- Waldemar Tomme
- Softwareentwickler:in
  - [bluehands GmbH & Co.mmunication KG](https://bluehands.de)
- Skills & Interessen:
  - .NET / C#
  - DevOps
  - Kubernetes / Container
  - Nix
  - Reverse Engineering

</v-clicks>

---

# Motivation - Monaden

```csharp {hide|1|3|5|all}
record Monad<T>(...);
{
  public static Monad<T> Return(T value) => ...;

  public Monad<TOut> Bind<TOut>(Func<T, Monad<TOut>> fn) => ...;
}
```
<v-after>

\+ 3 Gesetze (https://wiki.haskell.org/Monad_laws)

</v-after>

<!--
[click:4]
Monad Laws:
- Left Identity
  - `return a >>= h == h a`
  - `Monad<T>.Return(a).Bind(h) == h(a)`
- Right Identity
  - `m >>= return == m`
  - `m.Bind(Monad<T>.Return) == m`
- Associativity
  - `(m >>= g) >>= h == m >>= (\x -> g x >>= h)`
  - `m.Bind(g).Bind(h) == m.Bind(x => g(x).Bind(h))`
-->

---

# Motivation - Monaden

```csharp {hide|1|3-4|6-7|all}
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

```csharp {hide|all}
static TMonad<Lst<TOut>> BindT<TMonad, T, TOut>(
  TMonad<Lst<T>> ma,
  Func<T, TMonad<Lst<TOut>>> fn
) => ...
```

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
record Lst<T>;

record Id<T>(T Value)
{
  public static Id<T> Return(T value) => new(value);

  public Id<TOut> Bind<TOut>(Func<T, Id<TOut>> fn) => new(fn(Value));
}
```
```csharp
record Lst<T>;
record Id<T>;

static class LstT
{
  public static Id<Lst<TOut>> BindT<T, TOut>(
    this Id<Lst<T>> ma,
    Func<T, Id<Lst<TOut>>> fn
  ) =>
    new(ma.Value.Bind(x => fn(x).Value));
}
```
```csharp
record Lst<T>;
record Id<T>;

static class LstT
{
  public static Id<Lst<TOut>> BindT<T, TOut>(
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
record Lst<T>;
record Id<T>;

static class LstT
{
  public static IMonad<Lst<TOut>> BindT<T, TOut>(
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
record Lst<T>;
record Id<T>;

[MonadTransformer(typeof(Lst<>))]
static class LstT
{
  public static IMonad<Lst<TOut>> BindT<T, TOut>(
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
record Lst<T>;
record Id<T>;

[MonadTransformer(typeof(Lst<>))]
static class LstT;

[TransformMonad(typeof(Id<>), typeof(LstT))]
partial static class IdLst;
```
````

</v-click>

<!--
- [click] Lst Monad
- [click] Id Monad
- [click] Fixed IdLst Bind
- [click] Using Id's monad functions
- [click] Replacing Id with interface
- [click] Attaching source generator attribute
- [click] Defined transformed monad
-->

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

