<script>
  import Router from 'svelte-spa-router'
  import Home from "./routes/home.svelte"
  import Products from "./routes/products.svelte"
  import OrderRecent from "./routes/orderRecent.svelte"
  import Navigation from "./components/navigation.svelte"

  const routes = {
    '/': Home,
    '/products': Products,
    '/orderRecent': OrderRecent
  }
</script>

<Navigation />
<Router {routes}/>