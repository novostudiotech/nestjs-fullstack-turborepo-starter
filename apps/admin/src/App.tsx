import simpleRestProvider from 'ra-data-simple-rest';
import { Admin } from 'react-admin';

const dataProvider = simpleRestProvider('http://localhost:3000');

export function App() {
  return (
    <Admin dataProvider={dataProvider}>{/* <Resource name="users" list={ListGuesser} /> */}</Admin>
  );
}
