using FunicularSwitch.Generators;
using FunicularSwitch.Transformers;

namespace Demo;

[TestClass]
public class UnitTest1
{
    [TestMethod]
    public void TestMethod1()
    {
        var result = new Id<Lst<int>>(new([1]))
            .Bind(x => new Id<Lst<int>>(new(Enumerable.Range(0, x).ToList())));
    }
}

internal record Lst<T>(IReadOnlyList<T> Items)
{
    public static Lst<T> Return(T value) =>
        new([value]);

    public Lst<TOut> Bind<TOut>(Func<T, Lst<TOut>> fn) =>
        new(Items.SelectMany(x => fn(x).Items).ToList());
}

internal record Id<T>(T Value)
{
    public static Id<T> Return(T value) => new(value);

    public Id<TOut> Bind<TOut>(Func<T, Id<TOut>> fn) => new(fn(Value));
}

[MonadTransformer(typeof(Lst<>))]
static class LstT
{
    public static Monad<Lst<TOut>> BindT<T, TOut>(
        this Monad<Lst<T>> ma,
        Func<T, Monad<Lst<TOut>>> fn
    ) =>
        ma.Bind(xs => xs.Items.Aggregate(
            ma.Return<Lst<TOut>>(new([])),
            (acc, cur) => acc
                .Bind(ys => fn(cur)
                    .Map(ys_ => new Lst<TOut>([..ys.Items, ..ys_.Items])))
        ));
}

[TransformMonad(typeof(Id<>), typeof(LstT))]
internal static partial class IdLst;