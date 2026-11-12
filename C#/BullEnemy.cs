using UnityEngine;

namespace Portfolio.CSharpExamples
{
    public class BullEnemy : MonoBehaviour
    {
        public enum State { IDLE, CHASE, RUSH, HURT, COOLDOWN, DEATH }
        public State currentState = State.IDLE;

        [Header("Stats")]
        public int maxHealth = 8;
        public float moveSpeed = 30.0f;
        public float rushSpeed = 400.0f;
        public int contactDamage = 1;

        private int _health;
        private Transform _player;
        private Vector2 _facing = Vector2.down;
        private float _rushTimer = 5.0f;
        private Vector2 _rushTarget;
        private float _cooldownTimer = 1.0f;

        private void Start()
        {
            _health = maxHealth;
            GameObject playerObj = GameObject.FindGameObjectWithTag("Player");
            if (playerObj != null) _player = playerObj.transform;
        }

        private void Update()
        {
            // Note: In a standard Unity project, I would use FixedUpdate for physics/movement.
            // This is structured to match the Godot _physics_process(delta) logic.
            float delta = Time.deltaTime;

            switch (currentState)
            {
                case State.IDLE:
                    break;
                case State.CHASE:
                    TickChase(delta);
                    break;
                case State.RUSH:
                    TickRush(delta);
                    break;
                case State.HURT:
                    TickHurt(delta);
                    break;
                case State.COOLDOWN:
                    TickCooldown(delta);
                    break;
                case State.DEATH:
                    break;
            }
        }

        private void TickChase(float delta)
        {
            if (_player == null) { EnterState(State.IDLE); return; }

            Vector2 toPlayer = (Vector2)_player.position - (Vector2)transform.position;
            
            if (Mathf.Abs(toPlayer.x) > Mathf.Abs(toPlayer.y))
                _facing = new Vector2(Mathf.Sign(toPlayer.x), 0);
            else
                _facing = new Vector2(0, Mathf.Sign(toPlayer.y));

            transform.Translate(_facing * moveSpeed * delta);

            _rushTimer -= delta;
            if (_rushTimer <= 0.0f)
            {
                _rushTarget = _player.position;
                EnterState(State.RUSH);
            }
        }

        private void TickRush(float delta)
        {
            Vector2 dir = (_rushTarget - (Vector2)transform.position).normalized;
            transform.Translate(dir * rushSpeed * delta);

            if (Vector2.Distance(transform.position, _rushTarget) < 15.0f)
            {
                _cooldownTimer = 1.0f;
                EnterState(State.COOLDOWN);
            }
        }

        private void TickCooldown(float delta)
        {
            _cooldownTimer -= delta;
            if (_cooldownTimer <= 0.0f)
            {
                _rushTimer = 5.0f;
                EnterState(State.CHASE);
            }
        }

        private void TickHurt(float delta)
        {
            // Simulated knockback friction
        }

        public void EnterState(State newState)
        {
            currentState = newState;
            // Placeholder for Unity Animator state triggers:
            // GetComponent<Animator>().Play(newState.ToString());
        }

        public void TakeDamage(int amount, Vector2 fromDirection)
        {
            if (currentState == State.DEATH) return;

            _health -= amount;
            if (_health <= 0)
            {
                EnterState(State.DEATH);
                // Disable colliders here if necessary
                Destroy(gameObject, 1.0f);
                return;
            }

            EnterState(State.HURT);
            // Apply knockback logic here
        }
    }
}
