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
interface IMonad<TMonad, T> where TMonad : IMonad<TMonad, T>
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

---

# C#'s Grenzen

---

# Implementierung

---

# Zukunft
