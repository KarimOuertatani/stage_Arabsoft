import { Injectable } from '@angular/core';
import { Observable, of, throwError } from 'rxjs';
import { delay } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  login(username: string, password: string, rememberMe: boolean): Observable<boolean> {
    // Simule une authentification
    console.log('Login attempt:', { username, password, rememberMe });

    // Exemple : simule une réussite ou une erreur selon les credentials
    if (username === 'ng-matero' && password === 'ng-matero') {
      return of(true).pipe(delay(1000)); // Simule un appel API réussi
    } else {
      // Simule une erreur HTTP 422 avec un format compatible
      return throwError(() => ({
        status: 422,
        error: {
          errors: {
            username: ['Identifiant ou mot de passe incorrect'],
            password: ['Identifiant ou mot de passe incorrect'],
          },
        },
      })).pipe(delay(1000));
    }
  }
}