using System;
using UnityEngine;

namespace Portfolio.CSharpExamples
{
    public class FuelManager : MonoBehaviour
    {
        // In Unity, we use a Singleton pattern to make this globally accessible.
        public static FuelManager Instance { get; private set; }

        // Unity uses Events instead of Godot's signals.
        public event Action<float, float> OnFuelChanged;

        public const float MaxFuel = 15.0f;
        private const float DrainPerSecond = 0.15f;
        private const float RefillPerSecond = 15.0f;

        public float CurrentFuel { get; private set; } = MaxFuel;
        private int _refillPauseCount = 0;

        private void Awake()
        {
            // Singleton setup
            if (Instance != null && Instance != this)
            {
                Destroy(this);
            }
            else
            {
                Instance = this;
            }
        }

        private void Update()
        {
            // Time.deltaTime is Unity's equivalent to Godot's delta.
            if (_refill_pause_count > 0) return;
            
            if (CurrentFuel > 0.0f)
            {
                CurrentFuel = Mathf.Max(CurrentFuel - (DrainPerSecond * Time.deltaTime), 0.0f);
                OnFuelChanged?.Invoke(CurrentFuel, MaxFuel);
            }
        }

        public bool CanAfford(float cost = 1.0f)
        {
            return CurrentFuel >= cost;
        }

        public bool Spend(float cost = 1.0f)
        {
            if (!CanAfford(cost)) return false;
            
            CurrentFuel -= cost;
            OnFuelChanged?.Invoke(CurrentFuel, MaxFuel);
            return true;
        }

        public void RefillTick(float deltaTime)
        {
            if (CurrentFuel < MaxFuel)
            {
                CurrentFuel = Mathf.Min(CurrentFuel + (RefillPerSecond * deltaTime), MaxFuel);
                OnFuelChanged?.Invoke(CurrentFuel, MaxFuel);
            }
        }

        public void PauseRefill() => _refillPauseCount++;
        public void ResumeRefill() => _refillPauseCount = Mathf.Max(_refillPauseCount - 1, 0);
    }
}
