import { Admin, Resource, ListGuesser } from 'react-admin';
import simpleRestProvider from 'ra-data-simple-rest';

const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';
const dataProvider = simpleRestProvider(apiUrl);

export function App() {
  return (
    <Admin dataProvider={dataProvider}>
      {/* Add your resources here, e.g.: */}
      {/* <Resource name="users" list={ListGuesser} /> */}
    </Admin>
  );
}
