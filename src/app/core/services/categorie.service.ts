import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Categorie } from '../models/categorie';
import { AuthService } from '../authentication/auth.service';

@Injectable({
  providedIn: 'root'
})
export class CategorieService {
  private apiUrl = 'http://localhost:8081/api/categories';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  getAllCategories(): Observable<Categorie[]> {
    return this.http.get<Categorie[]>(this.apiUrl, { headers: this.getHeaders() });
  }
}