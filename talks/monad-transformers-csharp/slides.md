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

# Motivation
## Monaden

```csharp
record Monad<T>(...);
{
  public static Monad<T> Return(T value) => ...;

  public Monad<TOut> Bind<TOut>(Func<T, Monad<TOut>> fn) => ...;
}
```

\+ 3 Gesetze (https://wiki.haskell.org/Monad_laws)

---

# Motivation
## Monaden

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

# Motivation
## Higher Order Generics

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

---

# Motivation
## Monadentransformer

```csharp
static TMonad<Lst<TOut>> BindT<TMonad, T, TOut>(
  TMonad<Lst<T>> ma,
  Func<T, TMonad<Lst<T>>> fn
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

# Implementierung

---

# Demo

---

# Zukunft

---
layout: image-left
image: https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.PAq1g9lE92gIeyZmVLa6jgHaHY%3Fpid%3DApi&f=1&ipt=86cc5a28be669acc3bfc7584275add48e621043bb52611de106f31c00f5a0bf2&ipo=images
---

- https://github.com/bluehands/Funicular-Switch

---
layout: center
---

thx

