module namespace f = "http://www.w3.org/2005/xpath-functions-2025/generator";
declare namespace gn = "http://www.w3.org/2005/xpath-functions-2025/generator";

declare record f:generator 
   ( initialized as xs:boolean,
     end-reached as xs:boolean,
     get-current as fn($this as f:generator) as item()*,
     move-next as   fn($this as f:generator) as f:generator,           
     state as map(*)
   );

declare function gn:to-array($gen as f:generator) as array(*)
{
   while-do( [$gen, []],
          function( $in-out-args) 
          { $in-out-args(1)?initialized and not($in-out-args(1)?end-reached) },                 
          function($in-out-args) 
          { array{$in-out-args(1) =?> move-next(), 
                  array:append($in-out-args(2), $in-out-args(1) =?> get-current())
                 } 
           }         
 ) (2)
};

declare function gn:value($gen as f:generator) {$gen =?> get-current()};
declare function gn:next($gen as f:generator) {$gen =?> move-next()};

declare function gn:take($gen as f:generator, $n as xs:integer) as f:generator
{
  let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                else $gen
   return
     if($gen?end-reached or $n le 0) then gn:empty-generator()
      else
        let $current := $gen =?> get-current(),
            $newResultGen := map:put($gen, "get-current",   fn($this as f:generator){$current}),
            $nextGen := $gen =?> move-next()
         return
           if($nextGen?end-reached) then $newResultGen
             else
               let
                   $newResultGen2 :=  map:put($newResultGen, "move-next",   fn($this as f:generator) {gn:take($nextGen, $n -1)}) 
                 return
                   $newResultGen2  
};

declare function gn:take-while($gen as f:generator, $pred as function(item()*) as xs:boolean) as f:generator
{
  let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                else $gen
   return
     if($gen?end-reached) then gn:empty-generator()
      else      
        let $current := $gen =?> get-current()
          return
            if(not($pred($current))) then gn:empty-generator()
            else
              let $newResultGen := map:put($gen, "get-current",   fn($this as f:generator){$current}),
                  $nextGen := $gen =?> move-next()
               return
                  if($nextGen?end-reached) then $newResultGen
                  else
                    let $newResultGen2 :=  map:put($newResultGen, "move-next",   fn($this as f:generator) {gn:take-while($nextGen, $pred)}) 
                     return $newResultGen2    
};

declare function gn:skip-strict($gen as f:generator, $n as xs:nonNegativeInteger, $issueErrorOnEmpty as xs:boolean) as f:generator
{
  if($n eq 0) then $gen
    else if($gen?end-reached) 
           then if($issueErrorOnEmpty)
                 then error((), "Input Generator too-short") 
                 else gn:empty-generator()
    else 
      let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                   else $gen
        return
          if(not($gen?end-reached)) then gn:skip-strict($gen =?> move-next(), $n -1, $issueErrorOnEmpty)
            else gn:empty-generator()    
};

declare function gn:skip($gen as f:generator, $n as xs:nonNegativeInteger) as f:generator
{
  gn:skip-strict($gen, $n, false())
};
declare function gn:skip-while($gen as f:generator, $pred as function(item()*) as xs:boolean) as f:generator
{
  let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                else $gen
   return
     if($gen?end-reached) then gn:empty-generator()
      else
        let $current := $gen =?> get-current()
         return
           if(not($pred($current))) then $gen
            else gn:skip-while($gen =?> move-next(), $pred)  
};

declare function gn:subrange($gen as f:generator, $m as xs:positiveInteger, $n as xs:positiveInteger) as f:generator
{
 gn:take(gn:skip($gen, $m - 1), $n - $m + 1)  
};

declare function gn:some($gen as f:generator) as xs:boolean
{
 $gen?initialized and not($gen?end-reached)  
};

declare function gn:some-where($gen as f:generator, $pred) as xs:boolean
{
 gn:some(gn:filter($gen, $pred))
};

declare function gn:first-where($gen as f:generator, $pred as fn(item()*) as xs:boolean) as item()*
{
   $gen => gn:skip-while(fn($x as item()*){not($pred($x))}) => gn:head()
 (: gn:head(gn:filter($gen, $pred)) :)
};

declare function gn:chunk($gen as f:generator, $size as xs:positiveInteger) as f:generator
{
  let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                else $gen
   return
     if($gen?end-reached) then gn:empty-generator()
     else
       let $thisChunk := gn:to-array(gn:take($gen, $size)),
           $cutGen := gn:skip($gen, $size),
           $resultGen := $gen => map:put("get-current",   fn($this as f:generator){$thisChunk})
                              => map:put("move-next",   fn($this as f:generator){gn:chunk($cutGen, $size)})
        return $resultGen  
};

declare function gn:head($gen as f:generator) as item()* {gn:take($gen, 1) =?> get-current()};

declare function gn:tail($gen as f:generator) as f:generator {gn:skip-strict($gen, 1, true())};

declare function gn:at($gen as f:generator, $ind) as item()* {gn:subrange($gen, $ind, $ind) =?> get-current()};

declare function gn:contains($gen as f:generator, $value as item()*) as xs:boolean
     {
       let $gen := if(not($gen?initialized)) then  $gen =?> move-next()
                     else $gen
        return
          if($gen?end-reached) then false()
           else
             let $current := $gen =?> get-current()
               return
                  if(deep-equal($current, $value)) then true()
                   else gn:contains($gen =?> move-next(), $value) 
     };

declare function gn:for-each($gen as f:generator, $fun as function(*)) as f:generator
{
  let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                else $gen        
   return
     if($gen?end-reached) then gn:empty-generator()
      else
       let $current := $fun($gen =?> get-current()),
            $newResultGen := map:put($gen, "get-current",   fn($this as f:generator){$current}),
            $nextGen := $gen =?> move-next()
        return
          if($nextGen?end-reached) then $newResultGen
            else
              let $newResultGen2 :=  map:put($newResultGen, "move-next",   fn($this as f:generator) {gn:for-each($nextGen, $fun)}) 
                 return
                   $newResultGen2         
};

declare function gn:for-each-pair($gen as f:generator, $gen2 as f:generator, $fun as function(*)) as f:generator
{
  let $gen := if(not($gen?initialized)) then $gen =?> move-next()
              else $gen,
      $gen2 := if(not($gen2?initialized)) then $gen2 =?> move-next()
              else $gen2
   return
      if($gen?end-reached or $gen2?end-reached) then gn:empty-generator() 
       else  
         let $current := $fun($gen =?> get-current(), $gen2 =?> get-current()),
             $newResultGen := map:put($gen, "get-current",   fn($this as f:generator){$current}),
             $nextGen1 := $gen =?> move-next(),
             $nextGen2 := $gen2 =?> move-next()
          return
             if($nextGen1?end-reached or $nextGen2?end-reached) then $newResultGen
               else
                 let $newResultGen2 := map:put($newResultGen, "move-next",   fn($this as f:generator){gn:for-each-pair($nextGen1, $nextGen2, $fun)})
                   return
                     $newResultGen2      
};

declare function gn:zip($gen as f:generator, $gen2 as f:generator) as f:generator
{
  gn:for-each-pair($gen, $gen2, fn($x1, $x2){[$x1, $x2]})
};

declare function gn:concat($gen as f:generator, $gen2 as f:generator) as f:generator
      {
        let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                    else $gen,
            $gen2 := if(not($gen2?initialized)) then $gen2 =?> move-next()
                    else $gen2,
            $resultGen := if($gen?end-reached) then $gen2
                            else if($gen2?end-reached) then $gen
                            else
                              $gen  => map:put( "move-next", 
                                                  fn($this as f:generator)
                                                 {
                                                 let $nextGen := $gen =?> move-next()
                                                   return 
                                                     gn:concat($nextGen, $gen2)
                                                 }
                                              )                                   
        return 
           $resultGen            
      };
      
declare function gn:append($gen as f:generator, $value as item()*) as f:generator
      {
        let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                    else $gen,
            $genSingle := $gen => map:put("get-current",   fn($this as f:generator){$value})
                               => map:put("move-next",   fn($this as f:generator){gn:empty-generator()})
                               => map:put("end-reached", false())
         return
           gn:concat($gen, $genSingle)                    
      };  
      
declare function gn:prepend($gen as f:generator, $value as item()*) as f:generator
      {
        let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                    else $gen,
            $genSingle := gn:empty-generator() => gn:append($value)
         return
           gn:concat($genSingle, $gen)  
      };    
      
declare function gn:insert-at($gen as f:generator, $pos as xs:positiveInteger, $value as item()*) as f:generator
      {
        let $genTail := gn:skip-strict($gen, $pos - 1, true())
         return
            if($pos gt 1)
              then gn:concat(gn:append(gn:take($gen, $pos - 1), $value), $genTail)
              else gn:prepend($genTail, $value)               
      };     
      
declare function gn:remove-at($gen as f:generator, $pos as xs:nonNegativeInteger) as f:generator
      {
        let $genTail := gn:skip-strict($gen, $pos, true())
          return
            if($pos gt 1)
              then gn:concat(gn:take($gen, $pos - 1), $genTail)
              else $genTail
      };
      
declare function gn:remove-where($gen as f:generator, $predicate as function(item()*) as xs:boolean) as f:generator
      {
        let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                      else $gen
          return
            gn:filter($gen, fn($x){not($predicate($x))})  
      };      

declare function gn:distinct($gen as f:generator) as f:generator
      {
        let $gen := if(not($gen?initialized)) then $gen =?> move-next()
                      else $gen
         return
           if($gen?end-reached) then $gen
           else
             let $priorValue := $gen =?> get-current()
               return
                 $gen => map:put("move-next",   fn($this as f:generator){gn:distinct(gn:remove-where(gn:tail($gen), fn($x){deep-equal($priorValue, $x)}))})  
      };
     
declare function gn:replace($gen as f:generator, $funIsMatching as function(item()*) as xs:boolean, $replacement as item()*) as f:generator
      {
        if($gen?end-reached) then $gen
          else
            let $current := $gen =?> get-current()
              return
                if($funIsMatching($current))
                  then let $nextGen := $gen =?> move-next()
                     return
                       $gen => map:put("get-current",   fn($this as f:generator) {$replacement})
                            => map:put("move-next",   fn($this as f:generator) { $nextGen } 
                                  )
                  else (: $current is not the match for replacement :)
                    let $nextGen := $gen =?> move-next()
                      return $gen => map:put("move-next", 
                                             fn($this as f:generator)
                                           {
                                             let $intendedReplace := function($z) {$z => gn:replace($funIsMatching, $replacement)}
                                              return
                                                if($nextGen?end-reached) then $nextGen
                                                else $intendedReplace($nextGen)
                                           }
                                        )
      };      
      
declare function gn:reverse($gen as f:generator) as f:generator
{
  if($gen?end-reached) then gn:empty-generator()
    else
     let $current := $gen =?> get-current()
       return
         gn:append(gn:reverse(gn:tail($gen)), $current)
};  

declare function gn:filter($gen as f:generator, $pred as function(item()*) as xs:boolean) as f:generator
{
 if($gen?initialized and $gen?end-reached) then gn:empty-generator()
  else
    let $getNextGoodGen := function($gen as map(*), 
                                    $pred as function(item()*) as xs:boolean)
                           {gn:skip-while($gen, fn($x){not($pred($x))})},
        $gen := if($gen?initialized) then $gen 
                  else $gen =?> move-next(),
        $nextGoodGen := $getNextGoodGen($gen, $pred)                           
    return
      if($nextGoodGen?end-reached) then gn:empty-generator()
        else
          $nextGoodGen => map:put("move-next", 
                                  fn($this as f:generator) {gn:filter($nextGoodGen => gn:skip(1), $pred)})
};
 
declare function gn:fold-left($gen as f:generator, $init as item()*, $action as fn(*)) as item()*
{
  if($gen?end-reached) then $init
    else gn:fold-left(gn:tail($gen), $action($init, $gen =?> get-current()), $action)
};

declare function gn:fold-right($gen as f:generator, $init as item()*, $action as fn(item()*, item()*) as item()*) as item()*
{
  if($gen?end-reached) then $init
    else $action(gn:head($gen), gn:fold-right(gn:tail($gen), $init, $action))
};

declare function gn:fold-lazy($gen as f:generator, $init as item()*, $action as fn(*), $shortCircuitProvider as function(*)) as item()*
{
  if($gen?end-reached) then $init
  else
   let $current := $gen =?> get-current()
     return
       if(function-arity($shortCircuitProvider($current, $init)) eq 0)
         then $shortCircuitProvider($current, $init)()
         else $action($current, gn:fold-lazy($gen =?> move-next(), $init, $action, $shortCircuitProvider))
};

declare function gn:scan-left($gen as f:generator, $init as item()*, $action as fn(*)) as f:generator
{
  let $resultGen := gn:empty-generator() 
                        => map:put("end-reached", false())
                        => map:put("get-current",   fn($this as f:generator){$init})
   return
     if($gen?end-reached) 
       then $resultGen => map:put("move-next",   fn($this as f:generator){gn:empty-generator()})
       else
         let $resultGen := $resultGen => map:put("get-current",   fn($this as f:generator){$init}),
             $partialFoldResult := $action($init, $gen =?> get-current())
           return
             let $nextGen := $gen =?> move-next()
              return
                $resultGen => map:put("move-next",   fn($this as f:generator)
                                      { 
                                          gn:scan-left($nextGen, $partialFoldResult, $action)
                                       }
                                      )            
};

declare function gn:scan-right($gen as f:generator, $init as item()*, $action as fn(*)) as f:generator
{
  gn:reverse(gn:scan-left(gn:reverse($gen), $init, $action))                         
};

declare function gn:help-merge-sorted-generators($arrayOfGens as array(f:generator)) as f:generator
{
  if(array:empty($arrayOfGens)) then gn:empty-generator()
    else
      let $starts := $arrayOfGens => array:for-each(fn($gen){$gen => gn:value()}),
          $minVal := min($starts),
          $firstMinIndex := ($starts => array:index-where(fn($val){$val eq $minVal}))[1],
          $firstMinGenerator := $arrayOfGens($firstMinIndex),
          $newArrayOfGens := $arrayOfGens => array:remove($firstMinIndex),
          $trimmedGenerator := $firstMinGenerator => gn:skip(1),
          $newArOfGens2 := if(gn:some($trimmedGenerator)) 
                              then $newArrayOfGens => array:append($trimmedGenerator)
                              else $newArrayOfGens,      
         $result := f:generator(initialized := true(), end-reached := false(),
                             get-current := fn($this as f:generator)
                                              {$minVal},
                             move-next := fn($this as f:generator)
                                            {gn:help-merge-sorted-generators($this?state?inputGenerators )},
                             state := map{}      
                            ) => map:put("state", map{"inputGenerators": $newArOfGens2} )                   
       return
          $result
};

declare function gn:merge-sorted-generators($gen as f:generator) as f:generator
{
  gn:help-merge-sorted-generators($gen => gn:to-array())
};
 
declare function gn:make-generator($provider as function(array(*)) as array(*)) 
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
                    => map:put("get-current", fn($this as f:generator) {$this?state?current})
                    => map:put("move-next",  
                                 fn($this as f:generator) 
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

declare function gn:make-generator-from-array($input as array(*)) as f:generator
{
  let $size := array:size($input),
      $arrayProvider := fn($state as array(xs:integer?))
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

declare function gn:make-generator-from-sequence($input as item()*) as f:generator
{
  let $size := count($input),
      $seqProvider := fn($state as array(xs:integer?))
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
        
declare function gn:make-generator-from-map($inputMap as map(*)) as f:generator
{
          let $keys := map:keys($inputMap),
              $size := map:size($inputMap),
              $mapProvider := fn($state as array(xs:integer?))
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
        

declare function gn:to-sequence($gen as f:generator) as item()* {gn:to-array($gen) => array:items()}; 

declare function gn:to-map($generator as f:generator) as map(*)
        {
             map:merge($generator => gn:to-sequence())
        };    

declare function gn:empty-generator() as f:generator 
{
  f:generator(initialized := true(), end-reached := true(),
              get-current := fn($this as f:generator)
                                {error(QName('http://www.w3.org/2005/xqt-errors', 'err:FOGR0002'),"get-current() called on an empty-generator")},
              move-next := fn($this as f:generator)
                                {error(QName('http://www.w3.org/2005/xqt-errors', 'err:FOGR0002'),"move-next() called on an empty-generator")},
              state := map{}
           )
};