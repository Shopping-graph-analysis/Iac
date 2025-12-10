from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def index(self):
        self.client.get("/")

    @task
    def health_check(self):
        # Assuming a common health check endpoint exists
        self.client.get("/health")
