from django.shortcuts import render
from rest_framework import generics
from .models import ToDo
from .serializers import TodoSerializer

# Create your views here.
class TodoGetCreate(generics.ListCreateAPIView):
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer

class TodoUpdateDelete(generics.RetrieveUpdateDestroyAPIView):
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer