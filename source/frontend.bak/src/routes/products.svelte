<script>
  import fastapi from "../lib/api"

  let product = []

  function get_product() {
    fastapi('get', '/product/', {}, (json) => {
            product = json
        })
  }

  get_product()

</script>



<style>
  .image-container {
    height: 150px; 
    overflow: hidden;
  }
  
  .image-container img {
    height: 100%;
    object-fit: cover;
  }
</style>

<div class="container">
  <h2 class="mt-4">It's Products</h2>
  <table class="table">
    <tbody>    
      {#each product as product, i}
          {#if i % 5 === 0}
            <tr>
          {/if}
              <td>
                  <div class="col-md-12 px-1">
                      <div class="image-container">
                        <img src="{product.img_path}" alt="1" />
                      </div>
                  </div>
                  
                  <div class="card-body">
                      <h5 class="card-title">
                      {product.name}
                      </h5>
                      <p class="card-text">{product.category}</p>
                      <p class="card-text font-weight-bold">{product.price}원</p>            
                      <a href="" class="btn btn-sm btn-outline-primary">상세</a>
                      <a href="" class="btn btn-sm btn-outline-primary">장바구니</a>
                      <a href="" class="btn btn-sm btn-outline-primary">주문</a>
                  </div>
              </td>
          {#if i % 5 === 4 || i === product.length - 1}
            <tr></tr>
          {/if}
      {/each}
    </tbody>
  </table>
</div>