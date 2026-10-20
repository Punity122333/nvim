;; extends
;; The CMake grammar has no separate "[" / "]" tokens -- square brackets are
;; part of (unquoted_argument), so they cannot be captured on their own.
"(" @bracket.paren
")" @bracket.paren
"{" @bracket.curly
"}" @bracket.curly
