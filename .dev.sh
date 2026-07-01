#!/bin/bash

SESSION="main"

# 1. Check if the 'main' tmux session already exists
tmux has-session -t $SESSION 2>/dev/null
if [ $? -ne 0 ]; then
    # -------------------------------------------------------------------------
    # [Window 1] 'AI-CORE' - Dual-Agent Command Center
    # -------------------------------------------------------------------------
    # Start session with a single full-screen window
    tmux new-session -d -s $SESSION -n 'AI-CORE'
    
    # [Step 1] Split the main window horizontally first
    # Left (40%): Will be Agent A | Right (60%): Will be Helix
    tmux split-window -h -p 60 -t $SESSION:1.1
    
    # [Step 2] Launch commands in their respective initial layout
    tmux send-keys -t $SESSION:1.1 'agy' C-m  # Left Pane (1.1) -> Agent A
    tmux send-keys -t $SESSION:1.2 'hx .' C-m # Right Pane (1.2) -> Helix

    # [Step 3] Target the LEFT pane (1.1) and split it vertically for Agent B
    # This creates a beautiful stacked layout on the left without touching Helix
    tmux split-window -v -p 50 -t $SESSION:1.1
    tmux send-keys -t $SESSION:1.2 'agy' C-m  # New split becomes 1.2 (Agent B)

    # -------------------------------------------------------------------------
    # [Window 2] 'RUNTIME' - Clean Terminal for Flexible Commands
    # -------------------------------------------------------------------------
    tmux new-window -t $SESSION -n 'RUNTIME'
    tmux send-keys -t $SESSION:2 'clear' C-m

    # -------------------------------------------------------------------------
    # [Window 3] 'SANDBOX' - Version Control & Human Verification
    # -------------------------------------------------------------------------
    tmux new-window -t $SESSION -n 'SANDBOX'
    tmux send-keys -t $SESSION:3 'lazygit' C-m

    # -------------------------------------------------------------------------
    # Initial Focus Setup
    # -------------------------------------------------------------------------
    # Bring back focus to Window 1, Top-left pane (Agent A)
    tmux select-window -t $SESSION:1
    tmux select-pane -t $SESSION:1.1
fi

# 2. Attach to the configured tmux session
tmux attach-session -t $SESSION
