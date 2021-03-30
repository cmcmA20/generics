{-# OPTIONS --safe --without-K #-}
module Generics.Telescope where

open import Generics.Prelude


data Telescope {a} (A : Set a) : Setω

levelTel : ∀ {a} {A : Set a} → Telescope A → Level
tel      : ∀ {a} {A : Set a} → (T : Telescope A) → A → Set (levelTel T)

infixl 7 _⊢_

data Telescope A where
  ε   : Telescope A
  _⊢_ : ∀ (T : Telescope A) {ℓ} (f : Σ A (tel T) → Set ℓ) → Telescope A

levelTel ε = lzero
levelTel (_⊢_ T {ℓ} f) = levelTel T ⊔ ℓ

tel ε x = ⊤
tel (T ⊢ f) x = Σ[ t ∈ tel T x ] f (x , t)

ExTele : Telescope ⊤ → Setω
ExTele T = Telescope (tel T tt)

Σ[_⇒_] : (P : Telescope ⊤) (I : ExTele P) → Set (levelTel P ⊔ levelTel I)
Σ[ P ⇒ V ] = Σ (tel P tt) (tel V)

Σ[_⇒_&_] : (P : Telescope ⊤) (V I : ExTele P) → Set (levelTel P ⊔ levelTel V ⊔ levelTel I)
Σ[ P ⇒ V & I ] = Σ[ p ∈ tel P tt ] tel V p × tel I p

Curried : ∀ {a} {A : Set a} (T : Telescope A) ℓ x (P : tel T x → Set ℓ) → Set (ℓ ⊔ levelTel T)
Curried (ε           ) ℓ x P = P tt -- t tt
Curried (_⊢_ T {ℓ′} g) ℓ x P = Curried T (ℓ ⊔ ℓ′) x λ tt → (y : g (x , tt)) → P (tt , y)

uncurry : ∀ {a} {A : Set a} (T : Telescope A) ℓ x
          (P : tel T x → Set ℓ)
          (B : Curried T ℓ x P)
        → (y : tel T x) → P y
uncurry ε ℓ x P B tt = B
uncurry (_⊢_ T {ℓ′} f) ℓ x P B (tx , gx) =
  uncurry T (ℓ ⊔ ℓ′) x (λ p → (y : f (x , p)) → P (p , y)) B tx gx

Curried′ : ∀ P (I : ExTele P) ℓ → Set (levelTel P ⊔ levelTel I ⊔ lsuc ℓ)
Curried′ P I ℓ = Curried P (lsuc ℓ ⊔ levelTel I) tt λ p → Curried I (lsuc ℓ) p (const (Set ℓ))

uncurry′ : ∀ P (I : ExTele P) {ℓ} (A : Curried′ P I ℓ) → Σ[ P ⇒ I ] → Set ℓ
uncurry′ P I {ℓ} A (p , i) = uncurry I (lsuc ℓ) p _ (uncurry P _ tt _ A p) i