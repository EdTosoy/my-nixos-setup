; extends

; Inject 'angular' grammar into @Component({ template: `...` })
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

; Inject 'css' into @Component({ styles: [`...`] })
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
