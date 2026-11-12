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
        private string SavePath => Path.Combine(Application.persistentDataPath, "save_data.json");

        public bool HasStarted { get; private set; }
        public Vector2 SpawnPosition { get; private set; }
        public string[] OpenedGates { get; private set; } = new string[0];

        public void SaveGame()
        {
            var data = new SaveData
            {
                hasStarted = HasStarted,
                spawnX = SpawnPosition.x,
                spawnY = SpawnPosition.y,
                openedGates = OpenedGates
            };

            //This is simple data in this instance so I'm using Unity's built-in JsonUtility
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
