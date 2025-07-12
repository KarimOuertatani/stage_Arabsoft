import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { ApiService } from '../services/api.service';
import { catchError, map } from 'rxjs/operators';
import { Observable, of } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(private apiService: ApiService, private router: Router) {}

  canActivate(): Observable<boolean> {
    const token = localStorage.getItem('jwt_token');
    if (!token) {
      console.error('AuthGuard: No JWT token found in localStorage');
      this.router.navigate(['/login']);
      return of(false);
    }

    return this.apiService.getCurrentUser().pipe(
      map(user => {
        console.log('AuthGuard: Current user fetched:', user);
        if (user.typeUtilisateur === 'CLIENT') {
          return true;
        } else {
          console.error('AuthGuard: User is not ADMIN, typeUtilisateur:', user.typeUtilisateur);
          this.router.navigate(['/login']);
          return false;
        }
      }),
      catchError(err => {
        console.error('AuthGuard: Error fetching current user:', {
          status: err.status,
          statusText: err.statusText,
          message: err.message,
          error: err.error
        });
        this.router.navigate(['/login']);
        return of(false);
      })
    );
  }
}