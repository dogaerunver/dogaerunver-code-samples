using System;
using System.IO;
using UnityEngine;

namespace Portfolio.CSharpExamples
{
    [Serializable]
    public class SaveData
    {
        public bool hasStarted;
        public float spawnX;
        public float spawnY;
        public string[] openedGates;
    }

    public class GameState : MonoBehaviour
    {
        public static GameState Instance { get; private set; }

        private string SavePath => Path.Combine(Application.persistentDataPath, "save_data.json");

        public bool HasStarted { get; private set; }
        public Vector2 SpawnPosition { get; private set; }
        public string[] OpenedGates { get; private set; } = new string[0];

        private void Awake()
        {
            if (Instance != null && Instance != this) Destroy(this);
            else Instance = this;
        }

        public void AddKey(string key)
        {
            // Implementation for adding unlockable keys
        }

        public void SaveGame()
        {
            var data = new SaveData
            {
                hasStarted = HasStarted,
                spawnX = SpawnPosition.x,
                spawnY = SpawnPosition.y,
                openedGates = OpenedGates
            };

            string json = JsonUtility.ToJson(data, true);
            File.WriteAllText(SavePath, json);
            Debug.Log("Game Saved to: " + SavePath);
        }

        public void LoadGame()
        {
            if (!File.Exists(SavePath)) return;

            string json = File.ReadAllText(SavePath);
            SaveData data = JsonUtility.FromJson<SaveData>(json);

            if (data != null)
            {
                HasStarted = data.hasStarted;
                SpawnPosition = new Vector2(data.spawnX, data.spawnY);
                OpenedGates = data.openedGates;
            }
        }

        public void DeleteSave()
        {
            if (File.Exists(SavePath))
            {
                File.Delete(SavePath);
            }
        }
    }
}
