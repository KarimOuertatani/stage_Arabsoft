import { Component, OnInit, ViewChild, HostListener } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Commande, CommandeProduit } from '../models/commande.model';
import { Utilisateur } from '../models/utilisateur.model';
import { animate, state, style, transition, trigger } from '@angular/animations';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';

@Component({
  selector: 'app-orders',
  templateUrl: './orders.component.html',
  styleUrls: ['./orders.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule
  ],
  animations: [
    trigger('detailExpand', [
      state('collapsed', style({ height: '0px', minHeight: '0', display: 'none' })),
      state('expanded', style({ height: '*' })),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)'))
    ])
  ]
})
export class OrdersComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  commandes: Commande[] = [];
  orderColumns = ['id', 'dateCommande', 'clientId', 'statut', 'total', 'actions'];
  produitColumns = ['produitNom', 'quantite', 'prixUnitaire'];
  expandedCommande: Commande | null = null;
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  isSidenavCollapsed: boolean = false;
  windowWidth: number = window.innerWidth;

  orderChartData: ChartData<'pie'> = {
    labels: ['En Attente', 'Confirmée'],
    datasets: [
      {
        data: [0, 0],
        backgroundColor: ['#f59e0b', '#14b8a6'],
        borderColor: '#ffffff',
        borderWidth: 2
      }
    ]
  };

  chartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'right',
        labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } }
      },
      tooltip: {
        enabled: true,
        backgroundColor: '#1f2a44',
        titleFont: { family: 'Inter, Roboto, sans-serif' },
        bodyFont: { family: 'Inter, Roboto, sans-serif' }
      }
    }
  };

  constructor(private apiService: ApiService, private router: Router) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.isSidenavCollapsed = this.windowWidth <= 599;
  }

  ngOnInit() {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.isSidenavCollapsed = this.windowWidth <= 599;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadOrders();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  private loadOrders() {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.getCommandes().subscribe({
      next: (commandes) => {
        this.commandes = commandes;
        this.updateChartData();
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des commandes:', err);
        this.errorMessage = 'Failed to load orders. Please try again.';
        this.isLoading = false;
      }
    });
  }

  private updateChartData() {
    const counts = {
      EN_ATTENTE: 0,
      CONFIRMEE: 0
    };
    this.commandes.forEach(commande => counts[commande.statut]++);
    this.orderChartData.datasets[0].data = [counts.EN_ATTENTE, counts.CONFIRMEE];
  }

  toggleRow(commande: Commande) {
    this.expandedCommande = this.expandedCommande === commande ? null : commande;
  }

  isExpansionDetailRow = (i: number, row: Commande) => {
    return this.expandedCommande === row;
  }

  onAlertDismiss(): void {
    this.isShowAlert = false;
    localStorage.setItem('showAlert', 'false');
  }

  toggleTheme(): void {
    this.isDarkTheme = !this.isDarkTheme;
    localStorage.setItem('theme', this.isDarkTheme ? 'dark' : 'light');
    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  toggleSidenav(): void {
    this.isSidenavCollapsed = !this.isSidenavCollapsed;
    this.sidenav.toggle();
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadOrders();
  }
}