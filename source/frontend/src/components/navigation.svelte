<script>
    import { link } from 'svelte-spa-router'
</script>

<ul class="nav nav-tabs">
  <li class="nav-item">
    <a class="nav-link active" aria-current="page" href="#">Home</a>
  </li>
  <li class="nav-item">    
    <a use:link class="nav-link" href="/products">Products</a>    
  </li>
  <li class="nav-item">
    <a use:link class="nav-link" href="/orderRecent">Order Recent</a>
  </li>
  <li class="nav-item">
    <a class="nav-link disabled" href="#" tabindex="-1" aria-disabled="true">Disabled</a>
  </li>
</ul>