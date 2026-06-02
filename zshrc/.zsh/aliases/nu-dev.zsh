## @cmd nu-help-alias
## @desc List all nu dev aliases grouped by section
nu-help-alias() {
  local file="$HOME/.zsh/aliases/nu-dev.zsh"
  local section=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^#([A-Za-z][A-Za-z0-9-]*)$ ]]; then
      section="${match[1]}"
      printf "\n\033[1;36m%s\033[0m\n" "$section"
    elif [[ "$line" =~ ^alias[[:space:]]+([^=]+)=\'(.*)\'$ ]]; then
      printf "  \033[1m%-22s\033[0m %s\n" "${match[1]}" "${match[2]}"
    fi
  done < "$file"
  echo ""
}

#Aliases
## @cmd flutter-start
## @desc Start mini-meta-repo flutter desktop app
alias flutter-start='cd ~/dev/nu/mini-meta-repo && clear && flutter run -d macos -t lib/main_desktop.dart'

## @cmd stormguild-start
## @desc Start stormguild dev server
alias stormguild-start='cd ~/dev/nu/mini-meta-repo/stormguild && clear && npm run start:dev'

## @cmd stormguild-start-local
## @desc Start stormguild local server
alias stormguild-start-local='cd ~/dev/nu/mini-meta-repo/stormguild && clear && npm run start:local'

## @cmd finn-start
## @desc Start finn catalyst REPL (CO)
alias finn-start='cd ~/dev/nu/finn && clear && NU_COUNTRY=co lein catalyst-repl'

## @cmd trabalha-start
## @desc Start trabalha catalyst REPL
alias trabalha-start='cd ~/dev/nu/trabalha && clear && lein catalyst-repl'

## @cmd bd
## @desc Daily nu dev bd for BR/MX/CO + brag daily + Copilot review report (run & open; exec zsh at end)
alias bd='clear && nu dev bd --countries br,mx,co && pi update &&  just --justfile ~/dev/brag/justfile --working-directory ~/dev/brag daily && { ~/dev/nu/finn-copilot-observe/bin/copilot-review-report --repo nubank/finn --out ~/dev/nu/finn-copilot-observe/copilot-review-report.html && open ~/dev/nu/finn-copilot-observe/copilot-review-report.html; } && { claude -p "/ai-digest:ai-digest html" --dangerously-skip-permissions; open ~/dev/ai-digest/digest.html; }; exec zsh'

## @cmd cdnu
## @desc cd to ~/dev/nu/
alias cdnu='cd ~/dev/nu/'

## @cmd cdpi
## @desc cd to ~/dev/agents/
alias cdpi='cd ~/dev/agents/'

#Co
## @cmd trabalha-start-co
## @desc Start trabalha catalyst REPL (CO)
alias trabalha-start-co='cd ~/dev/nu/trabalha && clear && country=co lein catalyst-repl'

#Aliases-test
## @cmd finn-test
## @desc Run finn cashflow_global_flow tests
alias finn-test='cd ~/dev/nu/finn/test/flutter/ && flutter test test/flows/cashflow_global_flow/'

## @cmd finn-test-export
## @desc Run finn tests, write output to resultado.txt
alias finn-test-export='cd ~/dev/nu/finn/test/flutter/ && flutter test test/flows/cashflow_global_flow/ > resultado.txt '

## @cmd cff-mst-dynamo
## @desc Start cashflow-financing MST DynamoDB
alias cff-mst-dynamo='cd ~/dev/nu/cashflow-financing-multi-services-tests && clj -X dynamodb/run'
