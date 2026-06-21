; extends

; ------------------------------------------------------------
; Angular inline templates
; @Component({ template: `<div>...</div>` })
; Injects the 'angular' grammar so directives, bindings, and
; control-flow (@if/@for, *ngIf, [prop], (event), {{ interp }})
; get real highlighting instead of being treated as plain text.
; ------------------------------------------------------------
((call_expression
  function: (identifier) @_component
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @_key
        value: (template_string) @injection.content))))
 (#eq? @_component "Component")
 (#eq? @_key "template")
 (#set! injection.language "angular")
 (#offset! @injection.content 0 1 0 -1))

; ------------------------------------------------------------
; Angular inline styles
; @Component({ styles: [`.foo { color: red; }`] })
; Injects 'css' into each template string inside the styles array.
; ------------------------------------------------------------
((call_expression
  function: (identifier) @_component
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @_key
        value: (array
          (template_string) @injection.content)))))
 (#eq? @_component "Component")
 (#eq? @_key "styles")
 (#set! injection.language "css")
 (#offset! @injection.content 0 1 0 -1))
