import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Produit } from '../models/produit';
import { AuthService } from '../authentication/auth.service';

@Injectable({
  providedIn: 'root'
})
export class ProduitService {
  private apiUrl = 'http://localhost:8081/api/produits';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  getAllProduits(): Observable<Produit[]> {
    return this.http.get<Produit[]>(this.apiUrl, { headers: this.getHeaders() });
  }
}