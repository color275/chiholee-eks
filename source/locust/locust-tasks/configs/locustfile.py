# locust --host=http://localhost:8000
from locust import HttpUser, task, between
import os
import json
import random
from urllib.parse import urlparse

class MyUser(HttpUser):
    wait_time = between(1, 1)    

    @task
    def get_customer(self):
        id = random.randint(1, 100)
        response = self.client.get(f"/customer/get/{id}", name="/customer/get/id")    
    
    @task
    def get_product(self):
        id = random.randint(1, 20)
        response = self.client.get(f"/product/get/{id}", name="/product/get/id")    

    @task
    def get_order_details(self):
        order_id = random.randint(1, 10000)
        response = self.client.get(f"/order/get/{order_id}", name="/order/get/order_id")    

    @task
    def place_order(self):
        params = {
            'customer_id': random.randint(1, 100),
            'product_id': random.randint(1, 20)
        }
        response = self.client.post("/order/pay", params=params, name="/order/make_order")

    @task
    def order_update(self):
        params = {
            'order_id': random.randint(1, 1000),
            'order_cnt': random.randint(1, 10),
            'order_price': random.randint(1000, 100000)
        }
        response = self.client.put("/order/update", params=params, name="/order/update")        

    # @task
    # def get_order_recent(self):
    #     hours = random.choice([1,2,3])     
    #     response = self.client.get(f"/order/recent/{hours}", name=f"/order/recent_{hours}hour")

    @task
    def get_order_recent(self):
        response = self.client.get(f"/order/recent", name=f"/order/recent")

    @task
    def get_vip(self):
        response = self.client.get(f"/order/vip", name=f"/order/vip")

    @task
    def get_popular(self):
        response = self.client.get(f"/order/popular", name=f"/order/popular")

