{ pkgs, ... }:
{
  programs.skills-cli = {
    enable = true;
    sources = [
      # {
      #   repo = "git@github.com:softnetics/os.git";
      #   skills = [
      #     "far-blame"
      #   ];
      # }
      {
        repo = "mattpocock/skills#main";
        skills = [
          # Productivity
          "grill-me"
          "grilling"
          "handoff"
          "teach"
          "to-questionnaire"
          "wait-what"
          "writing-for-agents"
          # Engineering
          "code-review"
          "codebase-design"
          "diagnosing-bugs"
          "domain-modeling"
          "grill-with-docs"
          "implement"
          "improve-codebase-architecture"
          "prototype"
          "research"
          "resolving-merge-conflicts"
          "setup-matt-pocock-skills"
          "tad"
          "to-spec"
          "to-tickets"
          "triage"
          "wayfinder"
          "wizard"
        ];
      }
    ];
  };
}
