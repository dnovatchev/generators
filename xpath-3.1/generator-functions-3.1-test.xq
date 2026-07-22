import module namespace f = "http://www.w3.org/2005/xpath-functions-2025/generator" at "generator-functions-3.1.xqm" ;
declare namespace gn = "http://www.w3.org/2005/xpath-functions-2025/generator";


let $gen2ToInf := map{"initialized" : true(), 
                      "end-reached" : false(), 
                      "get-current" : function($this as map(*)){$this?state?last +1},
                      "move-next" :   function($this as map(*))
                      {
                        map:put($this, "state", map{"last": $this?state?last + 1})
                      },
                      "state" : map{"last" : 1}
                           },
    $genEmpty := map{"initialized" : true(), end-reached : false(),
                     "get-current" : function($this as map(*))
                                      {error((),"get-current() called on an empty-generator")},
                     "move-next" : function($this as map(*))
                                      {error((),"move-next() called on an empty-generator")},
                     "state" : map{}      
                    },
    $genN := $gen2ToInf => map:put("state", map{"last": 0}),
    $genFibo := map{"initialized" : true(), "end-reached" : false(),
                   "get-current" : function($this as map(*))
                                    {$this?state?current},
                   "move-next" : function($this as map(*))
                                   {map:put($this, "state", 
                                            map{"current": $this?state?next,
                                                "next": $this?state?current + $this?state?next                                                          
                                               }
                                           )},
                   "state" : map{"current": 0, "next": 1}      
                          },
    $gen0toInf := $gen2ToInf => map:put("state", map{"last": -1}),
    $double := function($n) {2*$n},
    $sum2 := function($m, $n) {$m + $n},
    $product := function($m, $n) {$m * $n},
    $factorial := function($n) {fold-left(1 to $n, 1, $product)}
  return    
  (
    "$gen2ToInf => gn:take(3) => gn:to-array()",
    $gen2ToInf => gn:take(3) => gn:to-array(),
    "$gen2ToInf => gn:take(10000000) => gn:value()",
    $gen2ToInf => gn:take(100000000) => gn:value(),
    "================",    
    "$gen2ToInf => gn:take(3) => gn:skip(2) => gn:value()",
    $gen2ToInf => gn:take(3) => gn:skip(2) => gn:value(),
    (: $gen2ToInf => gn:take(3) =?> move-next() =?> move-next() =?> move-next() =?> get-current(), :)
    "================",
    "$gen2ToInf => gn:value()",
    $gen2ToInf => gn:value(),
    "$gen2ToInf => gn:next() => gn:value()",
    $gen2ToInf => gn:next()  => gn:value(),
    "================",
    "$gen2ToInf => gn:take(5) instance of map(*)",
    $gen2ToInf => gn:take(5) instance of map(*),
    "gn:empty-generator() => gn:take(5) => gn:to-array()",
    gn:empty-generator() => gn:take(5) => gn:to-array(),
    "==>  $gen2ToInf => gn:skip(7) instance of map(*)",
    $gen2ToInf => gn:skip(7) instance of map(*),  
    "================",
    "$gen2ToInf => gn:subrange(4, 6) => gn:value()",
    $gen2ToInf => gn:subrange(4, 6) => gn:value(), 
    "$gen2ToInf => gn:subrange(4, 6) => gn:next() => gn:value()",
    $gen2ToInf => gn:subrange(4, 6) => gn:next() => gn:value(),
    "$gen2ToInf => gn:subrange(4, 6) => gn:next() => gn:next() => gn:value()",
    $gen2ToInf => gn:subrange(4, 6) => gn:next() => gn:next() => gn:value(),
    (: $gen2ToInf => gn:subrange(4, 6) =?> move-next() =?> move-next() =?> move-next() =?> get-current() :) (: Must raise error:)    
    "================",    
    "$gen2ToInf => gn:subrange(4, 6) => gn:head()",
    $gen2ToInf => gn:subrange(4, 6) => gn:head(),  
    "$gen2ToInf => gn:subrange(4, 6) => gn:tail() => gn:head()",
    $gen2ToInf => gn:subrange(4, 6) => gn:tail() => gn:head(),
    "$gen2ToInf => gn:subrange(4, 6) => gn:to-array()",
    $gen2ToInf => gn:subrange(4, 6) => gn:to-array(),
    "$gen2ToInf => gn:head()",
    $gen2ToInf => gn:head(),
    "==>  $gen2ToInf => gn:tail() => gn:head()",
    $gen2ToInf => gn:tail() => gn:head(),
    "================", 
    "$gen2ToInf => gn:subrange(4, 6) => gn:tail() => gn:to-array()",
    $gen2ToInf => gn:subrange(4, 6) => gn:tail() => gn:to-array(),
    (: $gen2ToInf => gn:empty-generator() => gn:tail() => gn:to-array(), :)
    "================",
    "$gen2ToInf => gn:at(5)",
    $gen2ToInf => gn:at(5), 
    "================",
    "$gen2ToInf => gn:subrange(1, 5) => gn:to-array()",
    $gen2ToInf => gn:subrange(1, 5) => gn:to-array(),
    "$gen2ToInf => gn:subrange(1, 5) => gn:for-each($double) => gn:to-array()",
    $gen2ToInf => gn:subrange(1, 5) => gn:for-each($double) => gn:to-array(),
    "$gen2ToInf => gn:take(5) => gn:for-each($double) => gn:to-array()",
    $gen2ToInf => gn:take(5) => gn:for-each($double) => gn:to-array(),
    "==>  $gen2ToInf => gn:for-each($double) => gn:take(5) => gn:to-array()",
    $gen2ToInf => gn:for-each($double) => gn:take(5) => gn:to-array(),
    "gn:empty-generator() => gn:for-each($double) => gn:to-array()",
    gn:empty-generator() => gn:for-each($double) => gn:to-array(),
    "================",
    "$gen2ToInf => gn:subrange(1, 5) => gn:to-array()",
    $gen2ToInf => gn:subrange(1, 5) => gn:to-array(),
    "$gen2ToInf => gn:subrange(6, 10) => gn:to-array()",
    $gen2ToInf => gn:subrange(6, 10) => gn:to-array(),
    "$gen2ToInf => gn:subrange(1, 5) => gn:for-each-pair($gen2ToInf => gn:subrange(6, 10), $sum2) => gn:to-array()",
    $gen2ToInf => gn:subrange(1, 5) => gn:for-each-pair($gen2ToInf => gn:subrange(6, 10), $sum2) => gn:to-array(), 
    "==>  $gen2ToInf => gn:for-each-pair($gen2ToInf, $sum2) => gn:take(5) => gn:to-array()",
    $gen2ToInf => gn:for-each-pair($gen2ToInf, $sum2) => gn:take(5) => gn:to-array(),
    "================",
    "==>  $gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:value()",
    $gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:value(),
    "$gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:next() => gn:value()",
    $gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:next() => gn:value(),
    "$gen2ToInf => gn:take(10) => gn:filter(function($n){$n gt 12}) => gn:to-array()",
    $gen2ToInf => gn:take(10) => gn:filter(function($n){$n gt 12}) => gn:to-array(),
    "gn:empty-generator() => gn:filter(function($n){$n eq $n}) => gn:to-array()",
    gn:empty-generator() => gn:filter(function($n){$n eq $n}) => gn:to-array(),
    "================", 
    "$gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:take(10) => gn:to-array()",
    $gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:take(10) => gn:to-array(),  
    "================", 
    "$gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:take(10) => gn:to-sequence()",
    $gen2ToInf => gn:filter(function($n){$n mod 2 eq 1}) => gn:take(10) => gn:to-sequence(),
    "================", 
    "$gen2ToInf => gn:take-while(function($n){$n lt 11}) => gn:to-array()",
    $gen2ToInf => gn:take-while(function($n){$n lt 11}) => gn:to-array(), 
    "$gen2ToInf => gn:take-while(function($n){$n lt 2}) => gn:to-array()",
    $gen2ToInf => gn:take-while(function($n){$n lt 2}) => gn:to-array(), 
    "$gen2ToInf => gn:take-while(function($n){$n lt 100000000}) => gn:value()",
    $gen2ToInf => gn:take-while(function($n){$n lt 100000000}) => gn:value(), 
    "================", 
    "$gen2ToInf => gn:skip-while(function($n){$n lt 11}) => gn:take(5) => gn:to-array()",
    $gen2ToInf => gn:skip-while(function($n){$n lt 11}) => gn:take(5) => gn:to-array(),
    "==> $gen2ToInf => gn:skip-while(function($n){$n lt 2}) => gn:take(5) => gn:to-array()",
    $gen2ToInf => gn:skip-while(function($n){$n lt 2})=> gn:take(5) => gn:to-array(),
    "gn:empty-generator() => gn:skip-while(function($n){$n lt 100}) => gn:to-array()",
    gn:empty-generator() => gn:skip-while(function($n){$n lt 100}) => gn:to-array(),
    "
     ==> $gen2ToInf => gn:skip-while(function($n){$n lt 2}) => gn:skip(1)",
     $gen2ToInf => gn:skip-while(function($n){$n lt 2}) => gn:skip(1),
    "$gen2ToInf => gn:some()",
     $gen2ToInf => gn:some(),
     "gn:empty-generator() => gn:some()",
     gn:empty-generator() => gn:some(),
    "================",
    "$gen2ToInf => gn:take(5) => gn:filter(function($n){$n ge 7}) => gn:some()",
     $gen2ToInf => gn:take(5) => gn:filter(function($n){$n ge 7}) => gn:some(),  
     "$gen2ToInf => gn:take(5) => gn:some-where(function($n){$n ge 7})",
     $gen2ToInf => gn:take(5) => gn:some-where(function($n){$n ge 7}), 
     "$gen2ToInf => gn:take(5) => gn:some-where(function($n){$n ge 6})",
     $gen2ToInf => gn:take(5) => gn:some-where(function($n){$n ge 6}),
     "$gen2ToInf => gn:some-where(function($n){$n ge 100})",
     $gen2ToInf => gn:some-where(function($n){$n ge 100}),
     "================",
     "$gen2ToInf => gn:take(10) => gn:take(11) => gn:to-array()",
     $gen2ToInf => gn:take(10) => gn:take(11) => gn:to-array(),
     "$gen2ToInf => gn:take(10) => gn:skip(10) => gn:to-array()",
     $gen2ToInf => gn:take(10) => gn:skip(10) => gn:to-array(),
     "$gen2ToInf => gn:take(10) => gn:skip(9) => gn:to-array()",     
     $gen2ToInf => gn:take(10) => gn:skip(9) => gn:to-array(),
     "$gen2ToInf => gn:skip(3) => gn:take(10) => gn:to-array()",
     $gen2ToInf => gn:skip(3) => gn:take(10) => gn:to-array(),
     "$gen2ToInf => gn:take(10) => gn:subrange(3, 13) => gn:to-array()",
     $gen2ToInf => gn:take(10) => gn:subrange(3, 13) => gn:to-array(),
     "$gen2ToInf => gn:take(10) => gn:subrange(5, 3) => gn:to-array()",
     $gen2ToInf => gn:take(10) => gn:subrange(5, 3) => gn:to-array(),
     "================",
     "$gen2ToInf => gn:chunk(10) => gn:value()",
      $gen2ToInf => gn:chunk(10) => gn:value(),
      "gn:empty-generator() => gn:chunk(20) => gn:some()",
      gn:empty-generator() => gn:chunk(20) => gn:some(),
      "==>  $gen2ToInf => gn:chunk(20) => gn:take(5) => gn:to-array()",
      $gen2ToInf => gn:chunk(20) => gn:take(5) => gn:to-array(),
     "================",
     "$gen2ToInf => gn:chunk(10) => gn:next() => gn:value()",
      $gen2ToInf => gn:chunk(10) => gn:next() => gn:value(),
     "$gen2ToInf => gn:take(100) => gn:chunk(20) => gn:next() => gn:next() => gn:value()", 
      $gen2ToInf => gn:take(100) => gn:chunk(20) => gn:next() => gn:next() => gn:value(),
     "$gen2ToInf => gn:take(100) => gn:chunk(20) => gn:skip(1) => gn:value()",      
      $gen2ToInf => gn:take(100) => gn:chunk(20) => gn:skip(1) => gn:value(),
     "================",      
     "$gen2ToInf => gn:take(100) => gn:chunk(20) => gn:for-each(function($genX){$genX}) => gn:to-array()",      
      $gen2ToInf => gn:take(100) => gn:chunk(20) => gn:for-each(function($genX){$genX}) => gn:to-array(),
     "================",  
     "$gen2ToInf => gn:take(10) => gn:chunk(4) => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:chunk(4) => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:chunk(4) => gn:for-each(function($arr){array:size($arr)}) => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:chunk(4) => gn:for-each(function($arr){array:size($arr)}) => gn:to-array(),
     "================", 
     "$gen2ToInf => gn:subrange(10, 15) => gn:concat($gen2ToInf => gn:subrange(1, 9)) => gn:to-array()",
     $gen2ToInf => gn:subrange(10, 15) => gn:concat($gen2ToInf => gn:subrange(1, 9)) => gn:to-array(),
     "gn:empty-generator() => gn:concat(gn:empty-generator()) => gn:to-array()",
     gn:empty-generator() => gn:concat(gn:empty-generator()) => gn:to-array(),
     "gn:empty-generator() => gn:concat($gen2ToInf => gn:take(1)) => gn:to-array()",
     gn:empty-generator() => gn:concat($gen2ToInf => gn:take(1)) => gn:to-array(),
     "$gen2ToInf => gn:take(1) => gn:concat(gn:empty-generator()) => gn:to-array()",
     $gen2ToInf => gn:take(1) => gn:concat(gn:empty-generator()) => gn:to-array(),
     "$gen2ToInf => gn:concat($gen2ToInf) => gn:value()",
     $gen2ToInf => gn:concat($gen2ToInf) => gn:value(),
     "================", 
     "$gen2ToInf => gn:subrange(1, 5) => gn:append(101) => gn:to-array()",
     $gen2ToInf => gn:subrange(1, 5) => gn:append(101) => gn:to-array(),
     "$gen2ToInf => gn:subrange(1, 5) => gn:prepend(101) => gn:to-array()",
     $gen2ToInf => gn:subrange(1, 5) => gn:prepend(101) => gn:to-array(),
     "==>  $gen2ToInf => gn:append(101)",
     $gen2ToInf => gn:append(101),
     "==>  $gen2ToInf => gn:append(101) => gn:value()",
     $gen2ToInf => gn:append(101) => gn:value(),
     "$gen2ToInf => gn:append(101) instance of map(*)",
     $gen2ToInf => gn:append(101) instance of map(*),
     "$gen2ToInf => gn:take(5) => gn:append(101) => gn:to-array()",
     $gen2ToInf => gn:take(5) => gn:append(101) => gn:to-array(),
     "gn:empty-generator() => gn:append(101) => gn:to-array()",
     gn:empty-generator() => gn:append(101) => gn:to-array(),
     "$gen2ToInf => gn:prepend(101) => gn:take(5) => gn:to-array()",
     $gen2ToInf => gn:prepend(101) => gn:take(5) => gn:to-array(),
     "================", 
     "$gen2ToInf => gn:subrange(1, 5) => gn:zip($gen2ToInf => gn:subrange(6, 10)) => gn:to-array()",
     $gen2ToInf => gn:subrange(1, 5) => gn:zip($gen2ToInf => gn:subrange(6, 10)) => gn:to-array(),
     "$gen2ToInf => gn:subrange(1, 5) => gn:zip($gen2ToInf => gn:subrange(10, 20)) => gn:to-array()",
     $gen2ToInf => gn:subrange(1, 5) => gn:zip($gen2ToInf => gn:subrange(10, 20)) => gn:to-array(),
     "==>  $gen2ToInf => gn:zip($gen2ToInf => gn:skip(5)) => gn:take(10) => gn:to-array()",
     $gen2ToInf => gn:zip($gen2ToInf => gn:skip(5)) => gn:take(10) => gn:to-array(),
     "$gen2ToInf => gn:subrange(1, 5) => gn:zip($gen2ToInf => gn:subrange(10, 20)) => gn:zip($gen2ToInf => gn:subrange(30, 40)) => gn:to-array()",
     $gen2ToInf => gn:subrange(1, 5) => gn:zip($gen2ToInf => gn:subrange(10, 20)) => gn:zip($gen2ToInf => gn:subrange(30, 40)) => gn:to-array(),
     "================", 
     "gn:make-generator(function($state as array(*))
                        {
                          let $numGenerated := if(array:empty($state)) then 0
                                               else $state(1)
                            return
                               if($numGenerated le 9) then [ [$numGenerated + 1], [$numGenerated + 1] ]
                                 else [[-1], []]
                        } 
                       ) => gn:to-array(),",

     gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                                        else $state(1)
                                     return
                                        if($numGenerated le 9) then [ [$numGenerated + 1], [$numGenerated + 1] ]
                                          else [[-1], []]
                                 } 
                             ) => gn:to-array(),
     "gn:make-generator(function($state as array(*))
                          {
                            let $numGenerated := if(array:empty($state)) then 0
                                                 else $state(1)
                             return
                               [ [$numGenerated + 1], [$numGenerated + 1] ]
                          } 
                        ) => gn:value()",                             
     gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                                        else $state(1)
                                     return
                                        [ [$numGenerated + 1], [$numGenerated + 1] ]
                                 } 
                             ) => gn:value(),  
     "gn:make-generator(function($state as array(*))
                          {
                            let $numGenerated := if(array:empty($state)) then 0
                                                 else $state(1)
                              return
                                 [ [$numGenerated + 1], [$numGenerated + 1] ]
                          } 
                       ) => gn:subrange(10, 15) => gn:to-array()",                                                        
     gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                                        else $state(1)
                                     return
                                        [ [$numGenerated + 1], [$numGenerated + 1] ]
                                 } 
                             ) => gn:subrange(10, 15) => gn:to-array(), 
     "(let $allNumbers :=  gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                                        else $state(1)
                                     return
                                        [ [$numGenerated + 1], [$numGenerated + 1] ]
                                 } 
                             )      
           
      return ($allNumbers => gn:value(), $allNumbers => gn:subrange(10, 15) => gn:to-array())",                           
      (let $allNumbers :=  gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                                        else $state(1)
                                     return
                                        [ [$numGenerated + 1], [$numGenerated + 1] ]
                                 } 
                             )      
           
      return ($allNumbers => gn:value(), $allNumbers => gn:subrange(10, 15) => gn:to-array()) 
    ),                
     "================", 
     "gn:make-generator-from-array([1, 4, 9, 16, 25]) => gn:to-array()",
      gn:make-generator-from-array([1, 4, 9, 16, 25]) => gn:to-array(),
      "gn:make-generator-from-array([]) => gn:to-array()",
      gn:make-generator-from-array([]) => gn:to-array(),      
      "gn:make-generator-from-sequence((1, 8, 27, 64, 125)) => gn:to-array()",
      gn:make-generator-from-sequence((1, 8, 27, 64, 125)) => gn:to-array(), 
     "================", 
     "$gen2ToInf => gn:take(10) => gn:insert-at(3, ""XYZ"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:insert-at(3, "XYZ") => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:insert-at(1, ""ABC"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:insert-at(1, "ABC") => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:insert-at(11, ""PQR"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:insert-at(11, "PQR") => gn:to-array(),
      "==>  $gen2ToInf => gn:insert-at(3, ""XYZ"") => gn:take(10) => gn:to-array()", 
      $gen2ToInf => gn:insert-at(3, "XYZ") => gn:take(10) => gn:to-array(),
     (:  $gen2ToInf => gn:take(10) => gn:insert-at(12, "GHI") => gn:to-array(), :)  (:  Must raise error "Input Generator too-short." :) 
     "================", 
     "$gen2ToInf => gn:take(10) => gn:remove-at(3) => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:remove-at(3) => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:remove-at(1) => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:remove-at(1) => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:remove-at(10) => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:remove-at(10) => gn:to-array(),
      "==>  $gen2ToInf => gn:remove-at(3) => gn:take(10) => gn:to-array()",
      $gen2ToInf => gn:remove-at(3) => gn:take(10) => gn:to-array(),
      (: , $gen2ToInf => gn:take(10) => gn:remove-at(11) => gn:to-array() :)        (:  Must raise error "Input Generator too-short." :) 
(::) 
     "================",
     "==>  $gen2ToInf => gn:remove-where(function($x){$x mod 3 eq 0}) => gn:take(10) => gn:to-array()",
      $gen2ToInf => gn:remove-where(function($x){$x mod 3 eq 0}) => gn:take(10) => gn:to-array(),   
       
     "================",
     "gn:make-generator-from-sequence((1,  3, 1, 2,  1, 2, 5, 2, 5)) => gn:distinct() => gn:to-array()",
      gn:make-generator-from-sequence((1,  3, 1, 2,  1, 2, 5, 2, 5)) => gn:distinct() => gn:to-array(),
      "$gen2ToInf => gn:for-each(function($n){$n idiv 10}) => gn:take(50) => gn:distinct() => gn:to-array()",
      $gen2ToInf => gn:for-each(function($n){$n idiv 10}) => gn:take(50) => gn:distinct() => gn:to-array(),
      "$gen2ToInf => gn:for-each(function($n){$n idiv 10}) => gn:take(100) => gn:distinct() => gn:to-array()",
      $gen2ToInf => gn:for-each(function($n){$n idiv 10}) => gn:take(100) => gn:distinct() => gn:to-array(),
      "==> $gen2ToInf => gn:for-each(function($n){$n idiv 10}) => gn:distinct() => gn:take(35) => gn:to-array()",
      $gen2ToInf => gn:for-each(function($n){$n idiv 10}) => gn:distinct() => gn:take(35) => gn:to-array(),
      "gn:empty-generator() => gn:distinct() => gn:to-array()",
      gn:empty-generator() => gn:distinct() => gn:to-array(),
     "================",          
     "$gen2ToInf => gn:take(10) => gn:replace(function($x){$x gt 4}, ""Replacement"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:replace(function($x){$x gt 4}, "Replacement") => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:replace(function($x){$x lt 3}, ""Replacement"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:replace(function($x){$x lt 3}, "Replacement") => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:replace(function($x){$x gt 10}, ""Replacement"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:replace(function($x){$x gt 10}, "Replacement") => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:replace(function($x){$x gt 11}, ""Replacement"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:replace(function($x){$x gt 11}, "Replacement") => gn:to-array(),
      "$gen2ToInf => gn:take(10) => gn:replace(function($x){$x lt 2}, ""Replacement"") => gn:to-array()",
      $gen2ToInf => gn:take(10) => gn:replace(function($x){$x lt 2}, "Replacement") => gn:to-array(),
      "==> $gen2ToInf => gn:replace(function($x){$x gt 4}, ""Replacement"") => gn:take(10) => gn:to-array()",
      $gen2ToInf => gn:replace(function($x){$x gt 4}, "Replacement") => gn:take(10) => gn:to-array(),
      "$gen2ToInf => gn:replace(function($x){$x lt 3}, ""Replacement"") => gn:take(10) => gn:to-array()",
      $gen2ToInf => gn:replace(function($x){$x lt 3}, "Replacement") => gn:take(10) => gn:to-array(),
    (:  
      Will result in endless loop:
      
      , "==>  ==>  ==>  $gen2ToInf => gn:replace(function($x){$x lt 2}, ""Replacement"") => gn:take(10) => gn:to-array() <==  <==  <==",
      $gen2ToInf?replace2(function($x){$x lt 2}, "Replacement") => gn:take(10) => gn:to-array() 
    :)
    "================",
    "gn:empty-generator() => gn:reverse() => gn:to-array()",
    gn:empty-generator() => gn:reverse() => gn:to-array(),
    "gn:empty-generator() => gn:append(2) => gn:reverse() => gn:to-array()",
    gn:empty-generator() => gn:append(2) => gn:reverse() => gn:to-array(),
    "$gen2ToInf => gn:take(10) => gn:reverse() => gn:to-array()",
    $gen2ToInf => gn:take(10) => gn:reverse() => gn:to-array(),
    "================",
    "$genN => gn:take(10) => gn:contains(3)",
    $genN => gn:take(10) => gn:contains(3),
    "$genN => gn:take(10) => gn:contains(20)",
    $genN => gn:take(10) => gn:contains(20),
    "$genN => gn:take(10) => gn:contains(1)",    
    $genN => gn:take(10) => gn:contains(1), 
    "$genN => gn:take(10) => gn:contains(10)",     
    $genN => gn:take(10) => gn:contains(10),  
    "$genN => gn:take(10) => gn:contains(0)",
    $genN => gn:take(10) => gn:contains(0), 
    "$genN => gn:take(10) => gn:contains(11)",        
    $genN => gn:take(10) => gn:contains(11),
    "==> $genN => gn:contains(15)",    
    $genN => gn:contains(15), 
    "================",
    "$gen2ToInf => gn:first-where(function($n){$n gt 10})",
    $gen2ToInf => gn:first-where(function($n){$n gt 10}),
    "$gen2ToInf => gn:chunk(10) =>  gn:first-where(function($arr as array(*)){$arr(1) le 33 and $arr(10) ge 33})",
    $gen2ToInf => gn:chunk(10) =>  gn:first-where(function($arr as array(*)){$arr(1) le 33 and $arr(10) ge 33}), 
    "================",
    "$gen2ToInf => gn:take(5) => gn:fold-left(0, function($x, $y){$x + $y})",
    $gen2ToInf => gn:take(5) => gn:fold-left(0, function($x, $y){$x + $y}),
    "gn:empty-generator() => gn:fold-left(54321, function($x, $y){$x + $y})",
    gn:empty-generator() => gn:fold-left(54321, function($x, $y){$x + $y}),
    "================",
    "$gen2ToInf => gn:take(5) => gn:fold-right(0, function($x, $y){$x + $y})",
    $gen2ToInf => gn:take(5) => gn:fold-right(0, function($x, $y){$x + $y}),
    "gn:empty-generator() => gn:fold-right(12345, function($x, $y){$x + $y})",
    gn:empty-generator() => gn:fold-right(12345, function($x, $y){$x + $y}),
    "================",
    "==> $gen0toInf => gn:for-each(function($n){(2 * $n + 1) div $factorial(2*xs:decimal($n)})
              => gn:take(8) => gn:fold-left(0, function($x, $y){$x + $y})",
    $gen0toInf => gn:for-each(function($n){(2*$n + 1) div $factorial(2*xs:decimal($n))}) => gn:take(8) => gn:fold-left(0, function($x, $y){$x + $y}),
    "================",    
    "$gen0toInf => gn:for-each(function($n){(2*$n + 1) div $factorial(2*xs:decimal($n))}) => gn:take(8) => gn:scan-left(0, function($x, $y){$x + $y}) => gn:to-array()",
    $gen0toInf => gn:for-each(function($n){(2*$n + 1) div $factorial(2*xs:decimal($n))}) => gn:take(8) => gn:scan-left(0, function($x, $y){$x + $y}) => gn:to-array(),
    "================",
    "let $genSeqE := $gen0toInf => gn:for-each(function($n){(2*$n + 1) div $factorial(2*xs:decimal($n))}) => gn:take(8) => gn:scan-left(0, function($x, $y){$x + $y}),
    $genSeqE-Next := $genSeqE => gn:tail(),
    $genZipped := $genSeqE => gn:zip($genSeqE-Next)
 return
    $genZipped => gn:first-where(function($pair){abs($pair(1) - $pair(2)) lt 0.000001})(2)",
    let $genSeqE := ($gen0toInf => gn:for-each(function($n){(2*$n + 1) div $factorial(2*xs:decimal($n))}) => gn:take(8)) => gn:scan-left(0, function($x, $y){$x + $y}),
        $genSeqE-Next := $genSeqE => gn:tail(),
        $genZipped := $genSeqE => gn:zip($genSeqE-Next)
      return
        ($genZipped => gn:first-where(function($pair){abs($pair(1) - $pair(2)) lt 0.000001}))(2),        
    "================",
    
    "gn:empty-generator() => gn:scan-left(0, function($x, $y){$x + $y}) => gn:to-array()",
    gn:empty-generator() => gn:scan-left(0, function($x, $y){$x + $y}) => gn:to-array(),
    "$gen2ToInf => gn:take(5) => gn:scan-left(0, function($x, $y){$x + $y}) => gn:to-array()",
    $gen2ToInf => gn:take(5) => gn:scan-left(0, function($x, $y){$x + $y}) => gn:to-array(),
    "================",
    "gn:make-generator-from-sequence((1 to 10)) => gn:scan-right(0, function($x, $y){$x + $y}) => gn:to-array()",
    gn:make-generator-from-sequence((1 to 10)) => gn:scan-right(0, function($x, $y){$x + $y}) => gn:to-array(),
    "$genN => gn:take(10) => gn:scan-right(0, function($x, $y){$x + $y}) => gn:to-array()",
    $genN => gn:take(10) => gn:scan-right(0, function($x, $y){$x + $y}) => gn:to-array(),
    "================",
    let $multShortCircuitProvider := function($x, $y)
        {
          if($x eq 0) then function(){0}
            else function($z) {$x * $z}
        },
        $gen-5ToInf := $gen2ToInf => gn:for-each(function($n){$n -7})
     return
     (
       "let $multShortCircuitProvider := function($x, $y)
        {
          if($x eq 0) then function(){0}
            else function($z) {$x * $z}
        },
            $gen-5ToInf := $gen2ToInf => gn:for-each(function($n){$n -7})
          return
            $gen2ToInf => gn:take(5) => gn:fold-lazy(1, $product, $multShortCircuitProvider),
            $gen-5ToInf => gn:fold-lazy(1, $product, $multShortCircuitProvider)",
       $gen2ToInf => gn:take(5) => gn:fold-lazy(1, $product, $multShortCircuitProvider),
       $gen-5ToInf => gn:fold-lazy(1, $product, $multShortCircuitProvider)
     ),
     "===============",
     "     let $myMap := {'John': 22, 'Ann': 28, 'Peter': 31}
      return 
        gn:make-generator-from-map($myMap) => gn:to-array()",
     let $myMap := {"John": 22, "Ann": 28, "Peter": 31}
      return 
        gn:make-generator-from-map($myMap) => gn:to-array(),
     "===============",        
     "let $myMap := {'John': 22, 'Ann': 28, 'Peter': 31},
          $genMap := gn:make-generator-from-map($myMap)
      return
        $genMap => gn:to-map()" ,
     let $myMap := {"John": 22, "Ann": 28, "Peter": 31},
         $genMap := gn:make-generator-from-map($myMap)
      return
        $genMap => gn:to-map(),
     "$gen2ToInf => gn:take(10) => gn:chunk(2) 
           => gn:for-each(function($chunk){map:entry($chunk(1), $chunk(2))})  
           => gn:to-map()",
     $gen2ToInf => gn:take(10) => gn:chunk(2) => gn:for-each(function($chunk){map:entry($chunk(1), $chunk(2))})  => gn:to-map()
     (: ,  $gen2ToInf => gn:take(10) => gn:to-map() :)
     (:  , gn:empty-generator() => gn:to-map() :)
     (: , $gen2ToInf => gn:make-generator-from-array([(), 5])  => gn:to-map()    :) 
     ,
     "=====================================
          let $matr := [
                   [11, 12, 13 , 14, 15], 
                   [21, 22, 23 , 24, 25], 
                   [31, 32, 33 , 34, 35], 
                   [41, 42, 43 , 44, 45] 
                 ],
         $len := $matr => array:size(),
         $Gen := $matr => array:for-each(function($row as array(*))
                                           {$row => gn:make-generator-from-array()}
                                         )
                             => gn:make-generator-from-array()
        return
          for $newRow in 1 to $len
            return
              $Gen =>gn:for-each( function($g as f:generator){$g =>gn:at($newRow) }) => gn:to-array()",
     let $matr := 
               [
                   [11, 12, 13 , 14, 15], 
                   [21, 22, 23 , 24, 25], 
                   [31, 32, 33 , 34, 35], 
                   [41, 42, 43 , 44, 45] 
                 ],
         $height := $matr => array:size(),
         $width := array:size($matr(1)),
         $Gen := $matr => array:for-each(function($row as array(*))
                                           {$row => gn:make-generator-from-array()}
                                         )
                             => gn:make-generator-from-array()
        return
        (
          array{
          for $newRow in 1 to $width
            return
              $Gen =>gn:for-each( function($g as map(*)){$g =>gn:at($newRow) }) => gn:to-array()
             }
           ),
      (:
         let $ar1 := [1, 3, 5, 7, 9, 11],
             $ar2 :=  [-100, -90, -80, -70, -60, -50],
             $ar3 := [-10, -8, -6, -4, -2, 0],
             $gn1 := gn:make-generator-from-array($ar1),
             $gn2 := gn:make-generator-from-array($ar2),
             $gn3 := gn:make-generator-from-array($ar3),
             $GenArs := gn:make-generator-from-array([$gn1, $gn2, $gn3]),
             $GenSorted := gn:empty-generator()
             return 
               let $minVal := min($GenArs => gn:for-each(function($gen){$gen => gn:value()}) => gn:to-array()),
                   $GenWithMin := $GenArs => gn:first-where(function($gen){$gen => gn:value() eq $minVal}),
                   $GenSorted := $GenSorted => gn:append($minVal)
                return
                   ($GenSorted => gn:to-array(), $GenWithMin),
        :)                   
         "=====================",
         "$genFibo => gn:subrange(1, 10) => gn:to-array()",
         $genFibo => gn:subrange(1, 10) => gn:to-array(),
         "$genFibo => gn:first-where(function($n) {$n gt 1000})",
         $genFibo => gn:first-where(function($n) {$n gt 1000}),
         "$genFibo => gn:for-each(function($k){$k mod 2}) => gn:subrange(1,20) => gn:to-array()",
         $genFibo => gn:for-each(function($k){$k mod 2}) => gn:subrange(1,20) => gn:to-array(),
         "gn:for-each(function($k){$k mod 3}) => gn:subrange(1,20) => gn:to-array()",
         $genFibo => gn:for-each(function($k){$k mod 3}) => gn:subrange(1,20) => gn:to-array(),
         "$genFibo => gn:filter(function($k) {$k mod 3 eq 0}) => gn:subrange(1,20) => gn:to-array()",
         $genFibo => gn:filter(function($k) {$k mod 3 eq 0}) => gn:subrange(1,20) => gn:to-array(),
         "$genFibo => gn:first-where(function($n){let $sqrt := math:sqrt($n) 
                                    return floor($sqrt) eq ceiling($sqrt) and $n gt 1})",
         $genFibo => gn:first-where(function($n){let $sqrt := math:sqrt($n) 
                                            return floor($sqrt) eq ceiling($sqrt) and $n gt 1}),
    "=====================================
         (let $genAncestorNodes := f:generator(initialized := true(), 
                                             end-reached := false(), 
                                             get-current := function($this as f:generator)
                                                              { let $current := $this?state?currentNode
                                                                 return if($current instance of document-node()) then '/'
                                                                          else $current/name()
                                                              },
                                             move-next :=   function($this as f:generator)
                                             {
                                                if(empty($this?state?currentNode/..))
                                                  then map:put($this, 'end-reached', true())
                                                  else
                                                    map:put($this, 'state', map{'currentNode': $this?state?currentNode/..})
                                              },
                                             state := map{'currentNode' : 
                                                                (
                                                                  parse-xml('<x>
                                                                               <y>
                                                                                 <z/>
                                                                               </y>
                                                                             </x>')//*[not(*)]
                                                               )[1]
                                                             }
                                            ) 
           return $genAncestorNodes => gn:to-array() 
    ",
    
                                                
         (let $genAncestorNodes := map{"initialized" : true(), 
                                       "end-reached" : false(), 
                                       "get-current" :   function($this as map(*))
                                                         { let $current := $this?state?currentNode
                                                            return if($current instance of document-node()) then '/'
                                                                     else $current/name()
                                                         },
                                       "move-next" :   function($this as map(*))
                                       { 
                                          if(empty($this?state?currentNode/..))
                                            then map:put($this, "end-reached", true())
                                            else
                                              map:put($this, "state", map{"currentNode": $this?state?currentNode/..})
                                        },
                                       "state" : map{"currentNode" : 
                                                          parse-xml(
                                                            '<x>
                                                               <y>
                                                                 <z/>
                                                               </y>
                                                             </x>')
                                                               //*[not(*)][1]
                                                       }
                                          } 
           return $genAncestorNodes => gn:to-array()         
   ),

   "=====================",
   "let $ar1 := [-100, -4, 1, 3, 5, 7, 9, 11],
       $ar2 :=  [-100, -90, -80, -70, -60, -50],
       $ar3 := [-10, -8, -6, -4, -2, 0, 15],
       $gn1 := gn:make-generator-from-array($ar1),
       $gn2 := gn:make-generator-from-array($ar2),
       $gn3 := gn:make-generator-from-array($ar3),
       $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])
     return
       gn:merge-sorted-generators($genOfGens) => gn:to-array()
   ",
     
   (   
     let $ar1 := [-100, -4, 1, 3, 5, 7, 9, 11],
       $ar2 :=  [-100, -90, -80, -70, -60, -50],
       $ar3 := [-10, -8, -6, -4, -2, 0, 15],
       $gn1 := gn:make-generator-from-array($ar1),
       $gn2 := gn:make-generator-from-array($ar2),
       $gn3 := gn:make-generator-from-array($ar3),
       $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])
     return
       gn:merge-sorted-generators($genOfGens) => gn:to-array()
   ),
"=====================",    
   "let  $ar1 := array {1 to 100_000_000_000},
         $ar2 := array {2 to 100_000_000_001},
         $ar3 := array {3 to 100_000_000_002},
         $gn1 := gn:make-generator-from-array($ar1),
         $gn2 := gn:make-generator-from-array($ar2),
         $gn3 := gn:make-generator-from-array($ar3),
         $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])
     return
       gn:merge-sorted-generators($genOfGens) => gn:subrange(1, 30) => gn:to-array()",
   (
     let $ar1 := array {1 to 100_000_000_000},
         $ar2 := array {2 to 100_000_000_001},
         $ar3 := array {3 to 100_000_000_002},
         $gn1 := gn:make-generator-from-array($ar1),
         $gn2 := gn:make-generator-from-array($ar2),
         $gn3 := gn:make-generator-from-array($ar3),
         $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])         
     return
       gn:merge-sorted-generators($genOfGens) => gn:subrange(1, 30) => gn:to-array()
   ),  
   "     let $gn1 := gn:make-generator(function($state as array(*))
                                  {
                                   let $numGenerated := if(array:empty($state)) then 0
                                       else $state[1]
                                    return
                                      [ [$numGenerated + 2], [$numGenerated + 2] ]
                                  }
                                 ),
         $gn2 := gn:make-generator(function($state as array(*))
                                  {
                                   let $numGenerated := if(array:empty($state)) then 0
                                       else $state[1]
                                    return
                                      [ [$numGenerated + 3], [$numGenerated + 3] ]
                                  }
                                 ),
         $gn3 := gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                       else $state[1]
                                    return
                                      [ [$numGenerated + 5], [$numGenerated + 5] ]
                                 }
                                 ),
         $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])       
     return
       gn:merge-sorted-generators($genOfGens) => gn:subrange(1, 40) => gn:to-array()",
   (
     let $gn1 := gn:make-generator(function($state as array(*))
                                  {
                                   let $numGenerated := if(array:empty($state)) then 0
                                       else $state[1]
                                    return
                                      [ [$numGenerated + 2], [$numGenerated + 2] ]
                                  }
                                 ),
         $gn2 := gn:make-generator(function($state as array(*))
                                  {
                                   let $numGenerated := if(array:empty($state)) then 0
                                       else $state[1]
                                    return
                                      [ [$numGenerated + 3], [$numGenerated + 3] ]
                                  }
                                 ),
         $gn3 := gn:make-generator(function($state as array(*))
                                 {
                                   let $numGenerated := if(array:empty($state)) then 0
                                       else $state[1]
                                    return
                                      [ [$numGenerated + 5], [$numGenerated + 5] ]
                                 }
                                 ),
         $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])
     return
       gn:merge-sorted-generators($genOfGens) => gn:subrange(1, 40) => gn:to-array()
   ),
   "=================",
  (
   let $gn1 := $gen2ToInf => gn:filter(function($n){$n mod 2 eq 0}),
       $gn2 := $gen2ToInf => gn:filter(function($n){$n mod 3 eq 0}),
       $gn3 := $gen2ToInf => gn:filter(function($n){$n mod 5 eq 0}),
       $genOfGens := gn:make-generator-from-array([$gn1, $gn2, $gn3])
    return
       gn:merge-sorted-generators($genOfGens) => gn:subrange(1, 40) => gn:to-array() 
  ), 
   "=================
      let $f := function($n) {math:sqrt($n) idiv 20}    
    return
      $genN => gn:at($f(100000000))",
   let $f := function($n) {math:sqrt($n) idiv 20}    
    return
      $genN => gn:at($f(100000000)),
   "=================
      let $f := function($n) {$factorial($n) div $factorial($n -2)}
     return
       $genN => gn:at($f(20))",      
     let $f := function($n) {$factorial($n) div $factorial($n -2)}
     return
       $genN => gn:at($f(20)),
    "=================
    let $square := function($n as xs:decimal) as xs:decimal {$n * $n}
      return
        $genN => gn:subrange(1, 10_000_000) => gn:for-each($square) => gn:subrange($square(10), $square(12))
                   => gn:fold-left(0, function($x, $y){$x + $y})
    ",
    let $square := function($n as xs:decimal) as xs:decimal {$n * $n}
      return
        $genN => gn:subrange(1, 10_000_000) => gn:for-each($square) => gn:subrange($square(10), $square(12))
                   => gn:fold-left(0, function($x, $y){$x + $y})
 )
