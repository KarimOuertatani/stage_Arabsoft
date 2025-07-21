import { Component, Input, ViewEncapsulation } from '@angular/core';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { UserPanel } from './user-panel';
import { MatSidenav } from "@angular/material/sidenav";

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss'],
  encapsulation: ViewEncapsulation.None,
  standalone: true,
  imports: [
    CommonModule,
    MatListModule,
    MatIconModule,
    MatToolbarModule,
    RouterLink,
    RouterLinkActive,
    UserPanel,
    MatSidenav
],
})
export class SidebarComponent {
  @Input() showUser: boolean = true;
  @Input() showHeader: boolean = true;

  navItems = [
    { icon: 'dashboard', label: 'Dashboard', route: '/dashboard' },
    { icon: 'people', label: 'Users', route: '/users' },
    { icon: 'shopping_cart', label: 'Orders', route: '/orders' },
    { icon: 'category', label: 'Categories', route: '/categories' },
    { icon: 'inventory_2', label: 'Products', route: '/products' },
    { icon: 'local_shipping', label: 'Deliveries', route: '/deliveries' },
  ];
}