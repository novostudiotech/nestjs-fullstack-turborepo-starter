export default {
  '*.{ts,js,tsx,jsx,json}': (files) => {
    if (files.length === 0) return [];
    return [`biome check --write ${files.join(' ')}`];
  },
};
