#!/bin/bash
sed -i "s/&rsquo;/’/g" $1
sed -i "s/&#8211;/--/g" $1
sed -i "s/&#8230;/.../g" $1
sed -i "s/&gt;/>/g" $1
sed -i "s/&lt;/</g" $1
sed -i "s/&#8212;/-/g" $1
sed -i "s/&#8217;/'/g" $1
sed -i "s/&#215;/×/g" $1
sed -i 's!<pre class="brush: plain; title: ; notranslate" title="">!```\n!g' $1
sed -i 's!<pre class="EnlighterJSRAW" data-enlighter-language="null">!```\n!g' $1
sed -i 's!<pre class="EnlighterJSRAW" data-enlighter-language="generic" data-enlighter-theme="" data-enlighter-highlight="" data-enlighter-linenumbers="" data-enlighter-lineoffset="" data-enlighter-title="" data-enlighter-group="">!```\n!g' $1
sed -i 's!<pre class="brush: perl; collapse: false; title: ; wrap-lines: false; notranslate" title="">!```\n!g' $1
sed -i 's!<pre class="brush: bash; title: ; notranslate" title="">!```\n!g' $1
sed -i 's!<pre class="EnlighterJSRAW" data-enlighter-language="generic">!```\n!g' $1
sed -i 's!</pre>!\n```!g' $1
sed -i 's!<pre>```!```\n!g' $1
sed -i 's!<pre>!```\n!g' $1
sed -i 's/<code>/`/g' $1
sed -i 's/<\/code>/`/g' $1
sed -i "s/featured_image/image/g" $1
