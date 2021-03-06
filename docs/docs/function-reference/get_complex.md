---
layout: page
title: get_complex 
nav_order: 4 
permalink: /function-reference/get_complex/
parent: Function reference
---


<table width="100%" summary="page for get_complex {simba}"><tr><td>get_complex {simba}</td><td style="text-align: right;">R Documentation</td></tr></table>

<h2>Access internal simulation variables</h2>

<h3>Description</h3>

<p>Extract complex simulation data from a simulation object
</p>


<h3>Usage</h3>

```R
get_complex(sim_obj, sim_uid)
```


<h3>Arguments</h3>

<table summary="R argblock">
<tr valign="top"><td><span style='font-family:&quot;SFMono-Regular&quot;,Menlo,Consolas,Monospace; font-size:0.85em'>sim_obj</span></td>
<td>
<p>A simulation object of class <span style='font-family:&quot;SFMono-Regular&quot;,Menlo,Consolas,Monospace; font-size:0.85em'>simba</span>, usually created by
new_sim</p>
</td></tr>
<tr valign="top"><td><span style='font-family:&quot;SFMono-Regular&quot;,Menlo,Consolas,Monospace; font-size:0.85em'>sim_uid</span></td>
<td>
<p>The unique identifier of a single simulation replicate. This
corresponds to the <span style='font-family:&quot;SFMono-Regular&quot;,Menlo,Consolas,Monospace; font-size:0.85em'>sim_uid</span> column in <span style='font-family:&quot;SFMono-Regular&quot;,Menlo,Consolas,Monospace; font-size:0.85em'>sim$results</span>.</p>
</td></tr>
</table>


<h3>Value</h3>

<p>The value of the complex simulation result data corresponding to the
supplied <span style='font-family:&quot;SFMono-Regular&quot;,Menlo,Consolas,Monospace; font-size:0.85em'>sim_uid</span>
</p>


<h3>Examples</h3>

```R
sim <- new_sim()
sim %<>% add_creator("create_data", function(n) {
  x <- runif(n)
  y <- 3 + 2*x + rnorm(n)
  data.frame(x=x, y=y)
})
sim %<>% set_levels("n"=c(10, 100, 1000))
sim %<>% set_config(num_sim=1)
sim %<>% set_script(function() {
  dat <- create_data(L$n)
  model <- lm(y~x, data=dat)
  return (list(
    "beta1_hat" = model$coefficients[[2]],
    ".complex" = model
  ))
})
sim %<>% run()
print(sim$results)
print(get_complex(sim, 1))
```

<hr /><div style="text-align: center;">[Package <em>simba</em> version 0.1.0.9000 ]</div>
