sealed class AgentPhase {
  const AgentPhase();
}

class AgentPhaseIdle extends AgentPhase {
  const AgentPhaseIdle();
}

class AgentPhaseThinking extends AgentPhase {
  const AgentPhaseThinking();
}

class AgentPhaseToolRunning extends AgentPhase {
  const AgentPhaseToolRunning(this.tool);
  final String tool;
}

class AgentPhaseTyping extends AgentPhase {
  const AgentPhaseTyping();
}
