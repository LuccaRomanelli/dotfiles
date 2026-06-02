return {
  {
    "Olical/conjure",
    init = function()
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false
      -- Recognize defflow/st/deftest in addition to deftest
      vim.g["conjure#client#clojure#nrepl#test#current_form_names"] =
        { "deftest", "st/deftest", "defflow", "defflow-co", "defflow-mx" }
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "clojure",
        callback = function(ev)
          local function run_conjure(action)
            local ok, mod = pcall(require, "conjure.client.clojure.nrepl.action")
            if not ok or not mod[action] then
              vim.notify("Conjure not connected to nREPL", vim.log.levels.WARN)
              return
            end

            -- Try to run the test directly first; if namespace not found,
            -- eval the file and retry
            mod[action]()
          end

          local opts = function(desc) return { buffer = ev.buf, desc = desc } end
          vim.keymap.set("n", "<leader>tr", function() run_conjure("run-current-test") end, opts("Run test under cursor"))
          vim.keymap.set("n", "<leader>tn", function() run_conjure("run-current-ns-tests") end, opts("Run tests in namespace"))
          vim.keymap.set("n", "<leader>ta", function() run_conjure("run-all-tests") end, opts("Run all loaded tests"))
        end,
      })
    end,
  },
}
