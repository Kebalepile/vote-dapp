module.exports = function date() {
  let object = new Date();
  return `${object.getFullYear()}/${object.getMonth() + 1}/${object.getDate()}`;
};
