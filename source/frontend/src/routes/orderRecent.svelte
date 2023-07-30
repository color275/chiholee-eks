<script>
    import fastapi from "../lib/api";

    let orderRecent = [];

    function get_orderRecent() {
        fastapi('get', '/order/recent/1', {}, (json) => {
            orderRecent = json;
            formatOrderTime();
        });

        function formatOrderTime() {
            const options = {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false,
            };

            orderRecent.forEach((order) => {
                const orderTime = new Date(order.last_update_time);
                const formattedTime = orderTime.toLocaleString('en-US', options).replace(',', '');
                order.last_update_time = formattedTime;
            });
        }
    }

    get_orderRecent();
</script>
<div class="container">
    <h2 class="mt-4">Order Recents</h2>

    <div id="orderList" class="mt-4">
      <table class="table">
        <thead>
          <tr>
            <th>No</th>
            <th>Customer Name</th>
            <th>Product Name</th>
            <th>Order Count</th>
            <th>Order Price</th>
            <th>Order Time</th>
          </tr>
        </thead>
        <tbody>
          {#each orderRecent as order, i}
          <tr>
            <td>{i+1}</td>
            <td>{order.customer_name}</td>
            <td>{order.product_name}</td>
            <td>{order.order_cnt}</td>
            <td>{order.order_price}</td>
            <td>{order.last_update_time}</td>
          </tr>
          {/each}
        </tbody>
      </table>
    </div>
</div>