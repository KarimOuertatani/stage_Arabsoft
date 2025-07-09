import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Commande } from '../models/commande.model';
import { Livraison } from '../models/livraison.model';
import { Produit } from '../models/produit.model';
import { Utilisateur } from '../models/utilisateur.model';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = 'http://192.168.1.11:8081/api';

  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('jwt_token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': token ? `Bearer ${token}` : ''
    });
  }

  getCommandes(): Observable<Commande[]> {
    return this.http.get<Commande[]>(`${this.apiUrl}/commande`, { headers: this.getHeaders() });
  }

  getLivraisons(): Observable<Livraison[]> {
    return this.http.get<Livraison[]>(`${this.apiUrl}/livraisons`, { headers: this.getHeaders() });
  }

  getProduits(): Observable<Produit[]> {
    return this.http.get<Produit[]>(`${this.apiUrl}/produits`, { headers: this.getHeaders() });
  }

  getUtilisateurs(): Observable<Utilisateur[]> {
    return this.http.get<Utilisateur[]>(`${this.apiUrl}/utilisateurs`, { headers: this.getHeaders() });
  }

  login(email: string, password: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/utilisateurs/login`, { email, motDePasse: password }, { headers: new HttpHeaders({ 'Content-Type': 'application/json' }) });
  }

  getCurrentUser(): Observable<Utilisateur> {
    return this.http.get<Utilisateur>(`${this.apiUrl}/utilisateurs/current`, { headers: this.getHeaders() });
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('client_id');
  }
}