import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Livraison } from '../models/livraison';
import { AuthService } from '../authentication/auth.service';

@Injectable({
  providedIn: 'root'
})
export class LivraisonService {
  private apiUrl = 'http://localhost:8081/api/livraisons';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  getAllLivraisons(): Observable<Livraison[]> {
    return this.http.get<Livraison[]>(this.apiUrl, { headers: this.getHeaders() });
  }
}