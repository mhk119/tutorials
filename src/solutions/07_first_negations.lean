import tuto_lib
import data.int.parity
/-
Negations, proof by contradiction and contraposition.

This file introduces the logical rules and tactics related to negation:
exfalso, by_contradiction, contrapose, by_cases and push_neg.

There is a special statement denoted by `false` which, by definition,
has no proof.

So `false` implies everything. Indeed `false → P` means any proof of 
`false` could be turned into a proof of P.
This fact is known by its latin name
"ex falso quod libet" (from false follows whatever you want).
Hence Lean's tactic to invoke this is called `exfalso`.
-/

example : false → 0 = 1 :=
begin
  intro h,
  exfalso,
  exact h,
end

/-
The preceding example suggests that this definition of `false` isn't very useful.
But actually it allows us to define the negation of a statement P as
"P implies false" that we can read as "if P were true, we would get 
a contradiction". Lean denotes this by `¬ P`.

One can prove that (¬ P) ↔ (P ↔ false). But in practice we directly
use the definition of `¬ P`.
-/

example {x : ℝ} : ¬ x < x :=
begin
  intro hyp,
  rw lt_iff_le_and_ne at hyp,
  cases hyp with hyp_inf hyp_non,
  clear hyp_inf, -- we won't use that one, so let's discard it
  change x = x → false at hyp_non, -- Lean doesn't need this psychological line
  apply hyp_non,
  refl,
end

open int

-- 0045
example (n : ℤ) (h_pair : even n) (h_non_pair : ¬ even n) : 0 = 1 :=
begin
  -- sorry
  exfalso,
  exact h_non_pair h_pair,
  -- sorry
end

-- 0046
example (P Q : Prop) (h₁ : P ∨ Q) (h₂ : ¬ (P ∧ Q)) : ¬ P ↔ Q :=
begin
  -- sorry
  split,
  { intro hnP,
    cases h₁ with hP hQ,
    { exfalso,
      exact hnP hP, },
    { exact hQ }, },
  { intros hQ hP,
    exact h₂ ⟨hP, hQ⟩ },
  -- sorry
end

/-
The definition of negation easily implies that, for every statement P,
P → ¬ ¬ P

The excluded middle axiom, which asserts P ∨ ¬ P allows us to
prove the converse implication.

Together those two implications form the principle of double negation elimination.
  not_not {P : Prop} : (¬ ¬ P) ↔ P

The implication `¬ ¬ P → P` is the basis for proofs by contradiction:
in order to prove P, it suffices to prove ¬¬ P, ie `¬ P → false`.

Of course there is no need to keep explaining all this. The tactic
`by_contradiction Hyp` will transform any goal P into `false` and 
add Hyp : ¬ P to the local context.

Let's return to a proof from the 5th file: uniqueness of limits for a sequence.
This cannot be proved without using some version of the excluded middle
axiom. We used it secretely in

eq_of_abs_sub_le_all (x y : ℝ) : (∀ ε > 0, |x - y| ≤ ε) → x = y

(we'll prove a variation on this lemma below).
-/
example (u : ℕ → ℝ) (l l' : ℝ) : seq_limit u l → seq_limit u l' → l = l' :=
begin
  intros hl hl',
  by_contradiction H,
  change l ≠ l' at H, -- Lean does not need this line
  have ineg : |l-l'| > 0,
    exact abs_pos_of_ne_zero (sub_ne_zero_of_ne H),
  cases hl ( |l-l'|/4 ) (by linarith) with N hN,
  cases hl' ( |l-l'|/4 ) (by linarith) with N' hN',
  let N₀ := max N N', -- this is a new tactic, whose effect should be clear
  specialize hN N₀ (le_max_left _ _),
  specialize hN' N₀ (le_max_right _ _),
  have clef : |l-l'| < |l-l'|,
    calc
    |l - l'| = |(l-u N₀) + (u N₀ -l')|   : by ring
         ... ≤ |l - u N₀| + |u N₀ - l'|  : by apply abs_add
         ... = |u N₀ - l| + |u N₀ - l'|  : by rw abs_sub
         ... < |l-l'|                    : by linarith,
  linarith, -- linarith can also find simple numerical contradictions
end

/-
Another incarnation of the excluded middle axiom is the principle of
contraposition: in order to prove P ⇒ Q, it suffices to prove
non Q ⇒ non P.
-/

-- Using a proof by contradiction, let's prove the contraposition principle
-- 0047
example (P Q : Prop) (h : ¬ Q → ¬ P) : P → Q :=
begin
  -- sorry
  intro hP,
  by_contradiction hnQ,
  exact h hnQ hP,
  -- sorry
end

/-
Again Lean doesn't need to be explain this principle. We can use the
`contrapose` tactic.
-/

example (P Q : Prop) (h : ¬ Q → ¬ P) : P → Q :=
begin
  contrapose,
  exact h,
end

/-
In the next exercise, we'll use
 odd n : ∃ k, n = 2*k + 1
 not_even_iff_odd : ¬ even n ↔ odd n,
-/
-- 0048
example (n : ℤ) : even (n^2) ↔ even n :=
begin
  -- sorry
  split,
  { contrapose,
    rw not_even_iff_odd,
    rw not_even_iff_odd,
    rintro ⟨k, rfl⟩,
    use 2*k*(k+1),
    ring },
  { rintro ⟨k, rfl⟩,
    use 2*k^2,
    ring },
  -- sorry
end
/-
As a last step on our law of the excluded middle tour, let's notice that, especially
in pure logic exercises, it can sometimes be useful to use the
excluded middle axiom in its original form:
  classical.em : ∀ P, P ∨ ¬ P

Instead of applying this lemma and then using the `cases` tactic, we
have the shortcut
 by_cases h : P,

combining both steps to create two proof branches: one assuming
h : P, and the other assuming h : ¬ P

For instance, let's prove a reformulation of this implication relation,
which is sometimes used as a definition in other logical foundations,
especially those based on truth tables (hence very strongly using
excluded middle from the very beginning).
-/

variables (P Q : Prop)

example : (P → Q) ↔ (¬ P ∨ Q) :=
begin
  split,
  { intro h,
    by_cases hP : P,
    { right,
      exact h hP },
    { left,
      exact hP } },
  { intros h hP,
    cases h with hnP hQ,
    { exfalso,
      exact hnP hP },
    { exact hQ } },
end

-- 0049
example : ¬ (P ∧ Q) ↔ ¬ P ∨ ¬ Q :=
begin
  -- sorry
  split,
  { intro h,
    by_cases hP : P,
    { right,
      intro hQ,
      exact h ⟨hP, hQ⟩ },
    { left,
      exact hP } },
  { rintros h ⟨hP, hQ⟩,
    cases h with hnP hnQ,
    { exact hnP hP },
    { exact hnQ hQ } },
  -- sorry
end

/-
It is crucial to understand negation of quantifiers. 
Let's do it by hand for a little while.
In the first exercise, only the definition of negation is needed.
-/

-- 0050
example (n : ℤ) : ¬ (∃ k, n = 2*k) ↔ ∀ k, n ≠ 2*k :=
begin
  -- sorry
  split,
  { intros hyp k hk,
    exact hyp ⟨k, hk⟩ },
  { rintros hyp ⟨k, rfl⟩,
    exact hyp k rfl },
  -- sorry
end

/-
Contrary to negation of the existential quantifier, negation of the
universal quantifier requires excluded middle for the first implication.
In order to prove this, we can use either
* a double proof by contradiction
* a contraposition, not_not : (¬ ¬ P) ↔ P) and a proof by contradiction.
-/

def even_fun (f : ℝ → ℝ) := ∀ x, f (-x) = f x

-- 0051
example (f : ℝ → ℝ) : ¬ even_fun f ↔ ∃ x, f (-x) ≠ f x :=
begin
  -- sorry
  split,
  { contrapose,
    intro h,
    rw not_not,
    intro x,
    by_contradiction H,
    apply h,
    use x,
    /- Alternative version
    intro h,
    by_contradiction H,
    apply h,
    intro x,
    by_contradiction H',
    apply H,
    use x, -/ },
  { rintros ⟨x, hx⟩ h',
    exact hx (h' x) },
  -- sorry
end

/-
Of course we can't keep repeating the above proofs, especially the second one.
So we use the `push_neg` tactic.
-/

example : ¬ even_fun (λ x, 2*x) :=
begin
  unfold even_fun, -- Here unfolding is important because push_neg won't do it.
  push_neg,
  use 42,
  linarith,
end

-- 0052
example (f : ℝ → ℝ) : ¬ even_fun f ↔ ∃ x, f (-x) ≠ f x :=
begin
  -- sorry
  unfold even_fun,
  push_neg,
  -- sorry
end

def bounded_above (f : ℝ → ℝ) := ∃ M, ∀ x, f x ≤ M

example : ¬ bounded_above (λ x, x) :=
begin
  unfold bounded_above,
  push_neg,
  intro M,
  use M + 1,
  linarith,
end

-- Let's contrapose
-- 0053
example (x : ℝ) : (∀ ε > 0, x ≤ ε) → x ≤ 0 :=
begin
  -- sorry
  contrapose,
  push_neg,
  intro h,
  use x/2,
  split ; linarith,
  -- sorry
end

/-
The "contrapose, push_neg" combo is so common that we can abreviate it to
`contrapose!`

Let's use this trick, together with:
  eq_or_lt_of_le : a ≤ b → a = b ∨ a < b
-/

-- 0054
example (f : ℝ → ℝ) : (∀ x y, x < y → f x < f y) ↔ (∀ x y, (x ≤ y ↔ f x ≤ f y)) :=
begin
  -- sorry
  split,
  { intros hf x y,
    split,
    { intros hxy,
      cases eq_or_lt_of_le hxy with hxy hxy,
      { rw hxy },
      { linarith [hf x y hxy]} },
    { contrapose!,
      apply hf } },
  { intros hf x y,
    contrapose!,
    intro h,
    rwa hf, }
  -- sorry
end
