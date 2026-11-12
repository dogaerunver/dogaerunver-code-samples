// this is a translation of my godot script into the C# and unity logic, it is only an example to show that I know how to handle this language too
using System;
using System.Collections.Generic;
using UnityEngine;

namespace Portfolio.CSharpExamples
{
    public class DialogueManager : MonoBehaviour
    {
      ,
        public event Action OnDialogueFinished;
        public event Action<string> OnChoiceMade;
        public event Action<string> OnTextSubmitted;

        private Dictionary<string, object> _currentNodeData;
        private bool _isCutsceneActive = false;
        private bool _pendingFail = false;

       
        [SerializeField] private GameObject dialogueUi;
        [SerializeField] private DialogueUI dialogueUiScript;

        private void Awake()
        {
            // Simulating Godot's .connect()
            if (dialogueUiScript != null)
            {
                dialogueUiScript.DialogueFinished += HandleDialogueFinished;
                dialogueUiScript.ChoiceMade += HandleChoiceMade;
                dialogueUiScript.TextSubmitted += HandleTextSubmitted;
            }
            dialogueUi.SetActive(false);
        }

        public void StartDialogue(string startNodeId)
        {
            _isCutsceneActive = true;
            _pendingFail = false;
            // Simulating Godot's get_tree().call_group()
            ToggleInteractables(false);
            
            LoadNode(startNodeId);
        }

        private void LoadNode(string nodeId)
        {
            _currentNodeData = DialogueData.GetDialogue(nodeId);

            if (_currentNodeData == null || _currentNodeData.Count == 0)
            {
                EndDialogue();
                return;
            }

            if (_currentNodeData.ContainsKey("action"))
            {
                ExecuteAction((string)_currentNodeData["action"]);
            }

            // Pass the data to the UI
            dialogueUiScript.StartDialogue(_currentNodeData);
        }

        private void HandleDialogueFinished()
        {
            if (_currentNodeData.ContainsKey("dynamic_next"))
            {
                var dynamicNextFunc = (Func<string>)_currentNodeData["dynamic_next"];
                string nextNode = dynamicNextFunc.Invoke();

                if (string.IsNullOrEmpty(nextNode)) EndDialogue();
                else LoadNode(nextNode);
            }
            else
            {
                string nextNode = _currentNodeData.ContainsKey("next") ? (string)_currentNodeData["next"] : "";
                if (string.IsNullOrEmpty(nextNode)) EndDialogue();
                else LoadNode(nextNode);
            }
        }

        private void HandleChoiceMade(string nextNodeId)
        {
            LoadNode(nextNodeId);
        }

        private void HandleTextSubmitted(string answer)
        {
            var validAnswers = _currentNodeData.ContainsKey("valid_answers") 
                ? (List<string>)_currentNodeData["valid_answers"] 
                : new List<string>();

            if (validAnswers.Contains(answer))
            {
                LoadNode((string)_currentNodeData["next_on_success"]);
            }
            else
            {
                LoadNode((string)_currentNodeData["next_on_fail"]);
            }
        }

        private void EndDialogue()
        {
            _isCutsceneActive = false;
            dialogueUiScript.HideUI();
            ToggleInteractables(true);

            if (_pendingFail)
            {
                // UnityEngine.SceneManagement.SceneManager.LoadScene("FailScene");
            }
        }

        private void ExecuteAction(string actionString)
        {
            string[] parts = actionString.Split(':');
            if (parts[0] == "add_key")
            {
                // Assuming GameState is a Singleton in Unity
                GameState.Instance.AddKey(parts[1]);
            }
            else if (parts[0] == "trigger_fail")
            {
                _pendingFail = true;
            }
        }

        private void ToggleInteractables(bool state)
        {
            // Simulating Godot's groups via Unity Tags or a custom manager
            // GameObject.FindGameObjectsWithTag("Interactable") ...
        }
    }
}
