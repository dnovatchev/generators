module namespace f = "http://www.w3.org/2005/xpath-functions-2025/generator";
declare namespace gn = "http://www.w3.org/2005/xpath-functions-2025/generator";
declare namespace hlp = "http://www.w3.org/2005/xpath-functions-2025/generator";

declare function hlp:while-do($input	as item()*,
                             $predicate	as function($input as item()*) as xs:boolean,
                             $action	as function($input as item()*) as item()*
                            ) as item()*
{
  if(not($predicate($input)) ) then $input
    else
      let $nextInput := $action($input)
       return
         hlp:while-do($nextInput, $predicate, $action)
      
};

declare function gn:to-array($gen as map(*)) as array(*)
{
   hlp:while-do( [$gen, []],
          function( $in-out-args) 
          { $in-out-args(1)?initialized and not($in-out-args(1)?end-reached) },                 
          function($in-out-args) 
          { array{$in-out-args(1) =?> move-next(), 
                  array:append($in-out-args(2), $in-out-args(1) =?> get-current())
                 } 
           }         
 ) (2)
};

declare function gn:value($gen as map(*)) {$gen ? get-current($gen)};
declare function gn:next($gen as map(*)) {$gen ? move-next($gen)};

declare function gn:take($gen as map(*), $n as xs:integer) as map(*)
{
  let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                else $gen
   return
     if($gen?end-reached or $n le 0) then gn:empty-generator()
      else
        let $current := $gen ? get-current($gen),
            $newResultGen := map:put($gen, "get-current",   function($this as map(*)){$current}),
            $nextGen := $gen ? move-next($gen)
         return
           if($nextGen?end-reached) then $newResultGen
             else
               let
                   $newResultGen2 :=  map:put($newResultGen, "move-next",   function($this as map(*)) {gn:take($nextGen, $n -1)}) 
                 return
                   $newResultGen2  
};

declare function gn:take-while($gen as map(*), $pred as function(item()*) as xs:boolean) as map(*)
{
  let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                else $gen
   return
     if($gen?end-reached) then gn:empty-generator()
      else      
        let $current := $gen ? get-current($gen)
          return
            if(not($pred($current))) then gn:empty-generator()
            else
              let $newResultGen := map:put($gen, "get-current",   function($this as map(*)){$current}),
                  $nextGen := $gen ? move-next($gen)
               return
                  if($nextGen?end-reached) then $newResultGen
                  else
                    let $newResultGen2 :=  map:put($newResultGen, "move-next",   
                                                   function($this as map(*)) {gn:take-while($nextGen, $pred)}) 
                     return $newResultGen2    
};

declare function gn:skip-strict($gen as map(*), $n as xs:nonNegativeInteger, $issueErrorOnEmpty as xs:boolean) as map(*)
{
  if($n eq 0) then $gen
    else if($gen?end-reached) 
           then if($issueErrorOnEmpty)
                 then error((), "Input Generator too-short") 
                 else gn:empty-generator()
    else 
      let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                   else $gen
        return
          if(not($gen?end-reached)) then gn:skip-strict($gen ? move-next($gen), $n -1, $issueErrorOnEmpty)
            else gn:empty-generator()    
};

declare function gn:skip($gen as map(*), $n as xs:nonNegativeInteger) as map(*)
{
  gn:skip-strict($gen, $n, false())
};
declare function gn:skip-while($gen as map(*), $pred as function(item()*) as xs:boolean) as map(*)
{
  let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                else $gen
   return
     if($gen?end-reached) then gn:empty-generator()
      else
        let $current := $gen ? get-current($gen)
         return
           if(not($pred($current))) then $gen
            else gn:skip-while($gen ? move-next($gen), $pred)  
};

declare function gn:subrange($gen as map(*), $m as xs:positiveInteger, $n as xs:positiveInteger) as map(*)
{
 gn:take(gn:skip($gen, $m - 1), $n - $m + 1)  
};

declare function gn:some($gen as map(*)) as xs:boolean
{
 $gen?initialized and not($gen?end-reached)  
};

declare function gn:some-where($gen as map(*), $pred as function(item()*) as xs:boolean) as xs:boolean
{
 gn:some(gn:filter($gen, $pred))
};

declare function gn:first-where($gen as map(*), $pred as function(item()*) as xs:boolean) as item()*
{
   $gen => gn:skip-while(function($x as item()*){not($pred($x))}) => gn:head()
 (: gn:head(gn:filter($gen, $pred)) :)
};

declare function gn:chunk($gen as map(*), $size as xs:positiveInteger) as map(*)
{
  let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                else $gen
   return
     if($gen?end-reached) then gn:empty-generator()
     else
       let $thisChunk := gn:to-array(gn:take($gen, $size)),
           $cutGen := gn:skip($gen, $size),
           $resultGen := $gen => map:put("get-current",   function($this as map(*)){$thisChunk})
                              => map:put("move-next",   fn($this as map(*)){gn:chunk($cutGen, $size)})
        return $resultGen  
};

declare function gn:head($gen as map(*)) as item()* {gn:take($gen, 1) ? get-current($gen)};

declare function gn:tail($gen as map(*)) as map(*) {gn:skip-strict($gen, 1, true())};

declare function gn:at($gen as map(*), $ind) as item()* {let $res := gn:subrange($gen, $ind, $ind) return $res ? get-current($res)};

declare function gn:contains($gen as map(*), $value as item()*) as xs:boolean
     {
       let $gen := if(not($gen?initialized)) then  $gen ? move-next($gen)
                     else $gen
        return
          if($gen?end-reached) then false()
           else
             let $current := $gen ? get-current($gen)
               return
                  if(deep-equal($current, $value)) then true()
                   else gn:contains($gen ? move-next($gen), $value) 
     };

declare function gn:for-each($gen as map(*), $fun as function(*)) as map(*)
{
  let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                else $gen        
   return
     if($gen?end-reached) then gn:empty-generator()
      else
       let $current := $fun($gen ? get-current($gen)),
            $newResultGen := map:put($gen, "get-current",   function($this as map(*)){$current}),
            $nextGen := $gen ? move-next($gen)
        return
          if($nextGen?end-reached) then $newResultGen
            else
              let $newResultGen2 :=  map:put($newResultGen, "move-next",   function($this as map(*)) {gn:for-each($nextGen, $fun)}) 
                 return
                   $newResultGen2         
};

declare function gn:for-each-pair($gen as map(*), $gen2 as map(*), $fun as function(*)) as map(*)
{
  let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
              else $gen,
      $gen2 := if(not($gen2?initialized)) then $gen2 ? move-next($gen2)
              else $gen2
   return
      if($gen?end-reached or $gen2?end-reached) then gn:empty-generator() 
       else  
         let $current := $fun($gen ? get-current($gen), $gen2 ? get-current($gen2)),
             $newResultGen := map:put($gen, "get-current",   fn($this as map(*)){$current}),
             $nextGen1 := $gen ? move-next($gen),
             $nextGen2 := $gen2 ? move-next($gen2)
          return
             if($nextGen1?end-reached or $nextGen2?end-reached) then $newResultGen
               else
                 let $newResultGen2 := map:put($newResultGen, "move-next",   
                                               function($this as map(*)){gn:for-each-pair($nextGen1, $nextGen2, $fun)})
                   return
                     $newResultGen2      
};

declare function gn:zip($gen as map(*), $gen2 as map(*)) as map(*)
{
  gn:for-each-pair($gen, $gen2, fn($x1, $x2){[$x1, $x2]})
};

declare function gn:concat($gen as map(*), $gen2 as map(*)) as map(*)
      {
        let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                    else $gen,
            $gen2 := if(not($gen2?initialized)) then $gen2 ? move-next($gen2)
                    else $gen2,
            $resultGen := if($gen?end-reached) then $gen2
                            else if($gen2?end-reached) then $gen
                            else
                              $gen  => map:put( "move-next", 
                                                  function($this as map(*))
                                                 {
                                                 let $nextGen := $gen ? move-next($gen)
                                                   return 
                                                     gn:concat($nextGen, $gen2)
                                                 }
                                              )                                   
        return 
           $resultGen            
      };
      
declare function gn:append($gen as map(*), $value as item()*) as map(*)
      {
        let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                    else $gen,
            $genSingle := $gen => map:put("get-current",   function($this as map(*)){$value})
                               => map:put("move-next",   function($this as map(*)){gn:empty-generator()})
                               => map:put("end-reached", false())
         return
           gn:concat($gen, $genSingle)                    
      };  
      
declare function gn:prepend($gen as map(*), $value as item()*) as map(*)
      {
        let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                    else $gen,
            $genSingle := gn:empty-generator() => gn:append($value)
         return
           gn:concat($genSingle, $gen)  
      };    
      
declare function gn:insert-at($gen as map(*), $pos as xs:positiveInteger, $value as item()*) as map(*)
      {
        let $genTail := gn:skip-strict($gen, $pos - 1, true())
         return
            if($pos gt 1)
              then gn:concat(gn:append(gn:take($gen, $pos - 1), $value), $genTail)
              else gn:prepend($genTail, $value)               
      };     
      
declare function gn:remove-at($gen as map(*), $pos as xs:nonNegativeInteger) as map(*)
      {
        let $genTail := gn:skip-strict($gen, $pos, true())
          return
            if($pos gt 1)
              then gn:concat(gn:take($gen, $pos - 1), $genTail)
              else $genTail
      };
      
declare function gn:remove-where($gen as map(*), $predicate as function(item()*) as xs:boolean) as map(*)
      {
        let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                      else $gen
          return
            gn:filter($gen, function($x){not($predicate($x))})  
      };      

declare function gn:distinct($gen as map(*)) as map(*)
      {
        let $gen := if(not($gen?initialized)) then $gen ? move-next($gen)
                      else $gen
         return
           if($gen?end-reached) then $gen
           else
             let $priorValue := $gen ? get-current($gen)
               return
                 $gen => map:put("move-next",   function($this as map(*))
                                     {gn:distinct(gn:remove-where(gn:tail($gen), fn($x){deep-equal($priorValue, $x)}))})  
      };
     
declare function gn:replace($gen as map(*), $funIsMatching as function(item()*) as xs:boolean, $replacement as item()*) as map(*)
      {
        if($gen?end-reached) then $gen
          else
            let $current := $gen ? get-current($gen)
              return
                if($funIsMatching($current))
                  then let $nextGen := $gen ? move-next($gen)
                     return
                       $gen => map:put("get-current",   function($this as map(*)) {$replacement})
                            => map:put("move-next",   function($this as map(*)) { $nextGen } 
                                  )
                  else (: $current is not the match for replacement :)
                    let $nextGen := $gen ? move-next($gen)
                      return $gen => map:put("move-next", 
                                             function($this as map(*))
                                           {
                                             let $intendedReplace := function($z) {$z => gn:replace($funIsMatching, $replacement)}
                                              return
                                                if($nextGen?end-reached) then $nextGen
                                                else $intendedReplace($nextGen)
                                           }
                                        )
      };      
      
declare function gn:reverse($gen as map(*)) as map(*)
{
  if($gen?end-reached) then gn:empty-generator()
    else
     let $current := $gen ? get-current($gen)
       return
         gn:append(gn:reverse(gn:tail($gen)), $current)
};  

declare function gn:filter($gen as map(*), $pred as function(item()*) as xs:boolean) as map(*)
{
 if($gen?initialized and $gen?end-reached) then gn:empty-generator()
  else
    let $getNextGoodGen := function($gen as map(*), 
                                    $pred as function(item()*) as xs:boolean)
                           {gn:skip-while($gen, fn($x){not($pred($x))})},
        $gen := if($gen?initialized) then $gen 
                  else $gen ? move-next($gen),
        $nextGoodGen := $getNextGoodGen($gen, $pred)                           
    return
      if($nextGoodGen?end-reached) then gn:empty-generator()
        else
          $nextGoodGen => map:put("move-next", 
                                  fn($this as map(*)) {gn:filter($nextGoodGen => gn:skip(1), $pred)})
};
 
declare function gn:fold-left($gen as map(*), $init as item()*, $action as function(*)) as item()*
{
  if($gen?end-reached) then $init
    else gn:fold-left(gn:tail($gen), $action($init, $gen ? get-current($gen)), $action)
};

declare function gn:fold-right($gen as map(*), $init as item()*, $action as function(item()*, item()*) as item()*) as item()*
{
  if($gen?end-reached) then $init
    else $action(gn:head($gen), gn:fold-right(gn:tail($gen), $init, $action))
};

declare function gn:fold-lazy($gen as map(*), $init as item()*, $action as function(*), $shortCircuitProvider as function(*)) as item()*
{
  if($gen?end-reached) then $init
  else
   let $current := $gen ? get-current($gen)
     return
       if(function-arity($shortCircuitProvider($current, $init)) eq 0)
         then $shortCircuitProvider($current, $init)()
         else $action($current, gn:fold-lazy($gen ? move-next($gen), $init, $action, $shortCircuitProvider))
};

declare function gn:scan-left($gen as map(*), $init as item()*, $action as function(*)) as map(*)
{
  let $resultGen := gn:empty-generator() 
                        => map:put("end-reached", false())
                        => map:put("get-current",   function($this as map(*)){$init})
   return
     if($gen?end-reached) 
       then $resultGen => map:put("move-next",   function($this as map(*)){gn:empty-generator()})
       else
         let $resultGen := $resultGen => map:put("get-current",   function($this as map(*)){$init}),
             $partialFoldResult := $action($init, $gen ? get-current($gen))
           return
             let $nextGen := $gen ? move-next($gen)
              return
                $resultGen => map:put("move-next",   function($this as map(*))
                                      { 
                                          gn:scan-left($nextGen, $partialFoldResult, $action)
                                       }
                                      )            
};

declare function gn:scan-right($gen as map(*), $init as item()*, $action as function(*)) as map(*)
{
  gn:reverse(gn:scan-left(gn:reverse($gen), $init, $action))                         
};

declare function gn:help-merge-sorted-generators($arrayOfGens as array(map(*))) as map(*)
{
  if(array:empty($arrayOfGens)) then gn:empty-generator()
    else
      let $starts := $arrayOfGens => array:for-each(function($gen){$gen => gn:value()}),
          $minVal := min($starts),
          $firstMinIndex := ($starts => array:index-where(fn($val){$val eq $minVal}))[1],
          $firstMinGenerator := $arrayOfGens($firstMinIndex),
          $newArrayOfGens := $arrayOfGens => array:remove($firstMinIndex),
          $trimmedGenerator := $firstMinGenerator => gn:skip(1),
          $newArOfGens2 := if(gn:some($trimmedGenerator)) 
                              then $newArrayOfGens => array:append($trimmedGenerator)
                              else $newArrayOfGens,      
         $result := map{"initialized" : true(), "end-reached" : false(),
                        "get-current" : function($this as map(*))
                                          {$minVal},
                         "move-next" : function($this as map(*))
                                        {gn:help-merge-sorted-generators($this?state?inputGenerators )},
                         "state" : map{}      
                          } => map:put("state", map{"inputGenerators": $newArOfGens2} )                   
       return
          $result
};

declare function gn:merge-sorted-generators($gen as map(*)) as map(*)
{
  gn:help-merge-sorted-generators($gen => gn:to-array())
};
 
declare function gn:make-generator($provider as function(array(*)) as array(*)) as map(*) 
{
 let  $providerResult := $provider([]),
      $nextProviderState := $providerResult(1),
      $nextDataItemHolder := $providerResult(2)
    return
      let $nextGen := if(array:empty($nextDataItemHolder)) 
                   then gn:empty-generator()  
                   else gn:empty-generator()
                    => map:put("state", map{"providerState": $nextProviderState,
                                            "current": $nextDataItemHolder(1) 
                                           })
                    => map:put("end-reached", false())
                    => map:put("get-current", function($this as map(*)) {$this?state?current})
                    => map:put("move-next",  
                                 fn($this as map(*)) 
                                {
                                  let $nextProviderResult := $provider($this?state?providerState),
                                      $nextDataItemHolder := $nextProviderResult(2)
                                    return
                                      if(array:empty($nextDataItemHolder)) then gn:empty-generator()
                                      else
                                        $this => map:put("state", map{"current": $nextDataItemHolder(1), 
                                                                      "providerState": $nextProviderResult(1)})
                                }
                               )
                             
   return $nextGen                                            
};   

declare function gn:make-generator-from-array($input as array(*)) as map(*)
{
  let $size := array:size($input),
      $arrayProvider := function($state as array(xs:integer?))
                        {
                          let $ind := if(array:empty($state))
                                      then 0
                                      else $state(1),
                              $newState := if($ind +1 gt $size) then []   
                                             else [$ind +1],
                              $newResult := if($ind +1 gt $size) then []
                                              else [$input($ind + 1)]
                           return [$newState, $newResult]
                        }
   return gn:make-generator($arrayProvider)
};  

declare function gn:make-generator-from-sequence($input as item()*) as map(*)
{
  let $size := count($input),
      $seqProvider := function($state as array(xs:integer?))
                        {
                          let $ind := if(array:empty($state))
                                      then 0
                                      else $state(1),
                              $newState := if($ind +1 gt $size) then []   
                                             else [$ind +1],
                              $newResult := if($ind +1 gt $size) then []
                                              else [$input[$ind + 1]] 
                           return [$newState, $newResult]                  
                        }
   return gn:make-generator($seqProvider)
};   
        
declare function gn:make-generator-from-map($inputMap as map(*)) as map(*)
{
          let $keys := map:keys($inputMap),
              $size := map:size($inputMap),
              $mapProvider := function($state as array(xs:integer?))
              {
                
                let $ind := if(array:empty($state))
                              then 0
                              else $state(1),
                    $newState := if($ind +1 gt $size) then []   
                                   else [$ind +1],
                    $newResult := if($ind +1 gt $size) then []
                                    else
                                       let $key := $keys[$ind + 1]
                                        return
                                          [map:entry($key, $inputMap($key))]
 
                  return [$newState, $newResult]                                      
             }                        
            return
              gn:make-generator($mapProvider)  
};
        

declare function gn:to-sequence($gen as map(*)) as item()* {gn:to-array($gen) => array:items()}; 

declare function gn:to-map($generator as map(*)) as map(*)
        {
             map:merge($generator => gn:to-sequence())
        };    

declare function gn:empty-generator() as map(*) 
{
  map {"initialized" : true(), "end-reached" : true(),
       "get-current" : function($this as map(*))
                          {error(QName('http://www.w3.org/2005/xqt-errors', 'err:FOGR0002'),"get-current() called on an empty-generator")},
        "move-next" : function($this as map(*))
                          {error(QName('http://www.w3.org/2005/xqt-errors', 'err:FOGR0002'),"move-next() called on an empty-generator")},
        "state" : map{}
         }
};