# Phase 1 Checklist: Backprop in 2 Evenings

> **Goal:** Understand backpropagation viscerally — not theoretically, but in your fingers.
> **Cost:** $0
> **Time:** ~3 hours total across 2 evenings
> **Prerequisites:** Python 3, numpy (`pip install numpy`)

---

## Evening 1: Build micrograd (1.5-2 hours)

### Step 1: Watch the map (15 min)
Open [Karpathy's micrograd video](https://www.youtube.com/watch?v=VMj-3P1m4pY) at 1.5x speed.
Watch only the first 30 minutes. You don't need to understand everything — just get the shape of it.

**Done when:** You can describe what a `Value` object does in one sentence.

### Step 2: Create the project (5 min)
```bash
mkdir ~/micrograd
cd ~/micrograd
touch engine.py
```

### Step 3: Implement the Value class (45 min)
Open `engine.py`. Implement this **without looking at Karpathy's code** as much as possible. When stuck, peek, then close the tab and write from memory.

```python
import math

class Value:
    def __init__(self, data, _children=(), _op='', label=''):
        self.data = data
        self.grad = 0.0
        self._backward = lambda: None
        self._prev = set(_children)
        self._op = _op
        self.label = label

    def __repr__(self):
        return f"Value(data={self.data})"

    def __add__(self, other):
        other = other if isinstance(other, Value) else Value(other)
        out = Value(self.data + other.data, (self, other), '+')
        def _backward():
            self.grad += out.grad
            other.grad += out.grad
        out._backward = _backward
        return out

    def __mul__(self, other):
        other = other if isinstance(other, Value) else Value(other)
        out = Value(self.data * other.data, (self, other), '*')
        def _backward():
            self.grad += other.data * out.grad
            other.grad += self.data * out.grad
        out._backward = _backward
        return out

    def __pow__(self, other):
        assert isinstance(other, (int, float))
        out = Value(self.data ** other, (self,), f'**{other}')
        def _backward():
            self.grad += (other * (self.data ** (other - 1))) * out.grad
        out._backward = _backward
        return out

    def __neg__(self): return self * -1
    def __sub__(self, other): return self + (-other)
    def __truediv__(self, other): return self * (other ** -1)

    def tanh(self):
        x = self.data
        t = (math.exp(2*x) - 1) / (math.exp(2*x) + 1)
        out = Value(t, (self,), 'tanh')
        def _backward():
            self.grad += (1 - t**2) * out.grad
        out._backward = _backward
        return out

    def exp(self):
        out = Value(math.exp(self.data), (self,), 'exp')
        def _backward():
            self.grad += out.data * out.grad
        out._backward = _backward
        return out

    def backward(self):
        topo = []
        visited = set()
        def build_topo(v):
            if v not in visited:
                visited.add(v)
                for child in v._prev:
                    build_topo(child)
                topo.append(v)
        build_topo(self)
        self.grad = 1.0
        for v in reversed(topo):
            v._backward()
```

### Step 4: Test it (15 min)
Create `test.py`:

```python
from engine import Value

# Build a simple expression
a = Value(2.0, label='a')
b = Value(3.0, label='b')
c = a * b; c.label = 'c'
d = Value(4.0, label='d')
e = c + d; e.label = 'e'
f = Value(-1.0, label='f')
L = e * f; L.label = 'L'

L.backward()
print(f"L = {L.data}")
print(f"a.grad = {a.grad}  (expected: -12.0)")
print(f"b.grad = {b.grad}  (expected: -8.0)")
```

Run it:
```bash
python test.py
```

**✅ VERIFICATION:** If `a.grad = -12.0` and `b.grad = -8.0`, your backprop works.

#### If it doesn't match:
- Check each operation's `_backward` function
- Common bug: forgetting `+=` instead of `=` in grad accumulation
- Check `__mul__`: `self.grad += other.data * out.grad`

### Step 5: The neuron (optional if you're on a roll)
Create `nn.py`:

```python
from engine import Value
import random

class Neuron:
    def __init__(self, nin):
        self.w = [Value(random.uniform(-1, 1)) for _ in range(nin)]
        self.b = Value(random.uniform(-1, 1))

    def __call__(self, x):
        act = sum((wi * xi for wi, xi in zip(self.w, x)), self.b)
        out = act.tanh()
        return out

    def parameters(self):
        return self.w + [self.b]
```

**Done when:** `python test.py` prints the expected gradients. If you got here, you understand backpropagation.

### 🛑 END OF EVENING 1 — STOP HERE. Sleep on it.

---

## Evening 2: Watch a network learn (1-1.5 hours)

### Step 1: Build a tiny network (15 min)
Add this to `nn.py`:

```python
class Layer:
    def __init__(self, nin, nout):
        self.neurons = [Neuron(nin) for _ in range(nout)]

    def __call__(self, x):
        outs = [n(x) for n in self.neurons]
        return outs[0] if len(outs) == 1 else outs

    def parameters(self):
        return [p for n in self.neurons for p in n.parameters()]

class MLP:
    def __init__(self, nin, nouts):
        sz = [nin] + nouts
        self.layers = [Layer(sz[i], sz[i+1]) for i in range(len(nouts))]

    def __call__(self, x):
        for layer in self.layers:
            x = layer(x)
        return x

    def parameters(self):
        return [p for l in self.layers for p in l.parameters()]
```

### Step 2: Generate data you can SEE (10 min)
Create `visualize.py`:

```python
from nn import MLP, Value
import numpy as np
import matplotlib.pyplot as plt

# DON'T install matplotlib if you don't have it — use this instead:
# pip install matplotlib

# Create a simple binary dataset
np.random.seed(42)
n_points = 20
X = np.random.randn(n_points, 2) * 1.5
y = (X[:, 0] * X[:, 1] > 0).astype(float) * 2 - 1  # XOR-like

# Normalize
X = (X - X.mean(axis=0)) / X.std(axis=0)

# Create MLP: 2 inputs, 16 hidden, 1 output
model = MLP(2, [16, 1])
params = model.parameters()
print(f"Parameters: {len(params)}")
```

### Step 3: Train and watch it learn (30 min)
Add to `visualize.py`:

```python
def train_step():
    # Forward pass
    ypred = [model(list(x)) for x in X]
    loss = sum((yout - yt)**2 for yout, yt in zip(ypred, y)) / len(y)
    
    # Backward pass
    for p in params:
        p.grad = 0.0
    loss.backward()
    
    # Update
    lr = 0.3
    for p in params:
        p.data -= lr * p.grad
    
    return loss.data

# Plot the decision boundary
def plot_decision_boundary(step):
    plt.clf()
    
    # Create a grid
    xx, yy = np.meshgrid(np.linspace(-3, 3, 50), np.linspace(-3, 3, 50))
    grid = np.c_[xx.ravel(), yy.ravel()]
    
    # Predict on grid
    preds = []
    for point in grid:
        out = model(list(point))
        preds.append(out.data)
    Z = np.array(preds).reshape(xx.shape)
    
    # Plot
    plt.contourf(xx, yy, Z, levels=20, cmap='RdBu', alpha=0.6)
    plt.scatter(X[:, 0], X[:, 1], c=y, cmap='RdBu', edgecolors='k', s=100)
    plt.title(f"Step {step}, Loss = {loss.data:.4f}")
    plt.xlim(-3, 3)
    plt.ylim(-3, 3)
    plt.pause(0.1)

plt.ion()
plt.figure(figsize=(8, 6))

for i in range(100):
    loss = train_step()
    if i % 10 == 0:
        plot_decision_boundary(i)
        print(f"Step {i}: loss = {loss:.4f}")

plt.ioff()
plt.show()
```

Run it:
```bash
python visualize.py
```

### ✅ What to watch for:
- **Steps 0-10:** The boundary is random. Loss is ~0.5-1.0.
- **Steps 10-30:** The boundary starts twisting. Loss drops below 0.3.
- **Steps 30-100:** The boundary cleanly separates the two clusters. Loss reaches ~0.05.

**If the boundary doesn't move:**
- Check that you're zeroing gradients before each backward pass
- Increase learning rate to 0.5 or 1.0
- Add more hidden neurons (32 instead of 16)

### 🛑 PHASE 1 COMPLETE

---

## What "Done" looks like

✅ Evening 1: `python test.py` gives correct gradients
✅ Evening 2: You watched a decision boundary evolve from random to separated
✅ You can explain in one sentence what backpropagation does

**If you hit both checkmarks, you understand the core mechanism of all neural networks. Move to Phase 2.**

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `python test.py` gives wrong grads | Check each `_backward` uses `+=`, not `=` |
| Nothing happens in visualization | Check matplotlib is installed (`pip install matplotlib`) |
| Decision boundary doesn't change | Increase learning rate to 1.0 |
| Loss goes to NaN | Lower learning rate to 0.01 |
| "I don't have matplotlib" | `pip install matplotlib` or use `print(loss)` instead of plotting |
| "I don't have numpy" | `pip install numpy` |
