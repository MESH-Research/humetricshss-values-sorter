/**
 * Fonts.js
 * Material design uses the Roboto Family. This script is responsible
 * for pulling it in asynchronously.
 *
 * http://www.google.com/design/spec/style/typography.html#typography-typeface
 */

const WebFontConfig = {
  google: { families: ['RobotoDraft:regular,medium,bold,italic:latin'] }
}
export default WebFontConfig;

(function () {
  const wf = document.createElement('script')
  wf.src = (document.location.protocol === 'https:' ? 'https' : 'http') +
    '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'
  wf.type = 'text/javascript'
  wf.async = 'true'
  const s = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore(wf, s)
})()
