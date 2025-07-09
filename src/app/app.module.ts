import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule, HttpClient } from '@angular/common/http';
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { MtxProgressModule } from '@ng-matero/extensions/progress';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { DashboardComponent } from './features/dashboard/dashboard.component';
import { UserService } from './core/services/user.service';
import { ProduitService } from './core/services/produit.service';
import { CategorieService } from './core/services/categorie.service';
import { CommandeService } from './core/services/commande.service';
import { LivraisonService } from './core/services/livraison.service';

export function HttpLoaderFactory(http: HttpClient) {
  return new TranslateHttpLoader(http, './assets/i18n/', '.json');
}

@NgModule({
  declarations: [
    AppComponent,
    DashboardComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    AppRoutingModule,
    MatCardModule,
    MatGridListModule,
    MtxAlertModule,
    MtxProgressModule,
    TranslateModule.forRoot({
      loader: {
        provide: TranslateLoader,
        useFactory: HttpLoaderFactory,
        deps: [HttpClient]
      }
    })
  ],
  providers: [UserService, ProduitService, CategorieService, CommandeService, LivraisonService],
  bootstrap: [AppComponent]
})
export class AppModule { }