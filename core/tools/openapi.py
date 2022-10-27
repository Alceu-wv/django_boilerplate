from django.contrib.auth.mixins import LoginRequiredMixin
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView


class LoginSpectacularSwaggerView(LoginRequiredMixin, SpectacularSwaggerView):
    pass


class LoginSpectacularRedocView(LoginRequiredMixin, SpectacularRedocView):
    pass


class LoginSpectacularAPIView(LoginRequiredMixin, SpectacularAPIView):
    pass