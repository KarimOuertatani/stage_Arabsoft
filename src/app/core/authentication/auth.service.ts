import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { switchMap, tap } from 'rxjs/operators';
import { LoginRequest, LoginResponse, Utilisateur } from '../models';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'http://localhost:8081/api/utilisateurs';
  private tokenKey = 'auth_token';

  constructor(private http: HttpClient) {}

  login(loginRequest: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.apiUrl}/login`, loginRequest).pipe(
      tap(response => {
        if (response.token) {
          localStorage.setItem(this.tokenKey, response.token);
        }
      }),
      switchMap(response => {
        return this.getCurrentUser().pipe(
          switchMap(user => {
            if (user.typeUtilisateur !== 'ADMIN') {
              localStorage.removeItem(this.tokenKey);
              return throwError(() => new Error('Seuls les administrateurs peuvent se connecter'));
            }
            return [response];
          })
        );
      })
    );
  }

  getCurrentUser(): Observable<Utilisateur> {
    const token = localStorage.getItem(this.tokenKey);
    if (!token) {
      return throwError(() => new Error('Aucun token trouvé'));
    }
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    return this.http.get<Utilisateur>(`${this.apiUrl}/current`, { headers });
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }
}