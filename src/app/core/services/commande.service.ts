import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Commande } from '../models/commande';
import { AuthService } from '../authentication/auth.service';

@Injectable({
  providedIn: 'root'
})
export class CommandeService {
  private apiUrl = 'http://localhost:8081/api/commande';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  getAllCommandesByClient(clientId: number): Observable<Commande[]> {
    return this.http.get<Commande[]>(`${this.apiUrl}/client/${clientId}`, { headers: this.getHeaders() });
  }
}