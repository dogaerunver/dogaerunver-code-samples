using System.Collections.Generic;
using UnityEngine;

namespace Portfolio.CSharpExamples
{
    public class SpellProjectile : MonoBehaviour
    {
    //I made the script draw the spell structure here but this can be separated
        [Header("Spell Settings")]
        public int segmentCount = 3;
        public Vector2 segmentSize = new Vector2(48, 32);
        public float segmentSpacing = 35.0f;
        public float segmentLifetime = 1.0f;
        public float segmentStepTime = 0.17f;
        public float startOffset = 40.0f;
        
        [SerializeField] private GameObject _segmentPrefab; // Assign a prefab in Unity

        private List<GameObject> _hitEnemies = new List<GameObject>();

        private void Start()
        {
            // using Unity's StartCoroutine as equivalent to Godot's "await get_tree().create_timer()"
            StartCoroutine(SpawnSegmentsRoutine());
        }

        private System.Collections.IEnumerator SpawnSegmentsRoutine()
        {
            for (int i = 0; i < segmentCount; i++)
            {
                SpawnSegment(i);
                yield return new WaitForSeconds(segmentStepTime);
            }

            yield return new WaitForSeconds(segmentLifetime);
            Destroy(gameObject);
        }

        private void SpawnSegment(int index)
        {
            Vector3 spawnPos = transform.position + (transform.right * (startOffset + index * segmentSpacing));
            GameObject segment = Instantiate(_segmentPrefab, spawnPos, transform.rotation);
            
            // Setup size and collision here based on prefab
            // StartCoroutine(DestroySegmentAfterTime(segment));
        }

        //this here assumes the segment has a script with an OnTriggerEnter event
        public void OnSegmentHit(GameObject enemy, Vector2 segmentPosition)
        {
            if (_hitEnemies.Contains(enemy)) return;
            
            _hitEnemies.Add(enemy);
            Vector2 dir = ((Vector2)enemy.transform.position - segmentPosition).normalized;
            
            // Assuming enemy has a TakeDamage method
            // enemy.GetComponent<BullEnemy>().TakeDamage(3, dir * 250.0f);
        }
    }
}
